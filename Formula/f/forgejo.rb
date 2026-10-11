class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.5/forgejo-src-16.0.5.tar.gz"
  sha256 "5d1199d7b58c977f025acd4f078d5ae535e537693ce600fd271652b84e3dca86"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0b8c9289b32e749db192a81ffa66053049d7b2284d5bc01b24f40faa280ea196"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1e1164dce33eca4d1e98644fb7d7ce00a2d89c6c7c3c2013827ef08fab144732"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "85a5b6ac725dc215b41b47b275279568658eded8ca494278de8a2e5fa491be34"
    sha256 cellar: :any,                 arm64_linux:       "11024e8f42df763e1cdd26d881fedfbc9b35f2c4f9051b655ea797920d912569"
    sha256 cellar: :any,                 x86_64_linux:      "dbd5bbdc47fd99ea27c76bf19b514b0fa60da2c5cfc8a4491c698eb726633490"
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
