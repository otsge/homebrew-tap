class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v17.0.1/forgejo-src-17.0.1.tar.gz"
  sha256 "d6b32ac77e71af0737f30613d985a0dc335b694b8b989d609a0cc88972f2fd4d"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5d8d6feb497d23be465cbfc9710970d87c2615c277ec85bc597d8f1ef5a1b1a0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4b1ad9ab2229ab9b920c0ca554b77e47a35e51bc3c8b149bd61b04681d084434"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4283d2979509dcf88a6aad00b404c54bba99df8160618ada3e90d3747149b5ad"
    sha256 cellar: :any,                 arm64_linux:       "1ae42f6410b301ae2d97c97f75aca9ab63affd3f556c82a1e9b743a00d12e521"
    sha256 cellar: :any,                 x86_64_linux:      "4259bcd0b4ce088b56fef4c6c95768339e77f19116609a2f2a1d31e8779b8b1f"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea" => "forgejo"
    bin.install "environment-to-ini"

    generate_completions_from_executable(bin/"forgejo", "completion")
    # powershell completion uses "pwsh" as the shell name
    # instead of the usual "powershell" used by generate_completions_from_executable
    (pwsh_completion/"forgejo").write Utils.safe_popen_read({ "SHELL" => "pwsh" }, bin/"forgejo",
                                                            "completion", "pwsh")
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path var/"log/forgejo.log"
    error_log_path var/"log/forgejo.log"
  end

  test do
    ENV["FORGEJO_WORK_DIR"] = testpath
    port = free_port

    pid = spawn bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s

    output = shell_output("curl --silent --retry 5 --retry-connrefused http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl --silent http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
