class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v17.0.2/forgejo-src-17.0.2.tar.gz"
  sha256 "5b08f6c24819aeb62b80f2f50f989cfcdfde0a8887f66438cbf32b556b1b6efb"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ed58ffd316915e7c3595f3a32911a9cdf8367395de83bb0bd9fdc9eef99775a3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "73e7529ee1b0f08e7abfff822d5704063215bcfecfa5de1992eea02f7d3eb72a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "db91bf8c060a7a7828c6ea2aac3a1c7dcaf7ce1d9056e61814f6c91782e754b0"
    sha256 cellar: :any,                 arm64_linux:       "f0decb248347d6b12f30b50e7797a1bf6d96f208cbdaf8952aa593c02f302f60"
    sha256 cellar: :any,                 x86_64_linux:      "2fbe2b84b8b1edef0b9eef7d3a2249a04b974707c0b6dbe437f5788a0c7fb91b"
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
