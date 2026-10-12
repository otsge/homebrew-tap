class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.6/forgejo-src-16.0.6.tar.gz"
  sha256 "0fe93c0bc4e1006ec3aa7d65be51181cc02efe4974c4237bb23723d954ffa630"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "824d518125b5bd2ef1274ff0c6cb24bc4e20179df2b52415c569f819eac06202"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "5847d321b836f61343ee6ccf4f168e3f219907ac7382a4e0134e6a4eff767aec"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "d1a408b8828b3a4c712d0ddbce2198edcd377e579ede3c1c6b288c16aacb1143"
    sha256 cellar: :any,                 arm64_linux:       "6c2c026085b5f02fecac86c5f774000a8c599187a11f6f6eca07f2a846bc7e59"
    sha256 cellar: :any,                 x86_64_linux:      "c33c23d01ed893031331905945964a32d4868dd8d1dee164aca8c4ddeb497516"
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
