class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v17.0.1/forgejo-src-17.0.1.tar.gz"
  sha256 "d6b32ac77e71af0737f30613d985a0dc335b694b8b989d609a0cc88972f2fd4d"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "95ae429b97aad75c6d5bb9b027fc4078f10defdadd844a7fa18a36206f65a719"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "aaaef57de3c35801ae8f519a63db3bbd8c667ba12f7b3dbad053f1c4cb95dc1a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ff20227f7c577e99e75de4ee92dcf7b35ff968058ebb5963476625cff8f51955"
    sha256 cellar: :any,                 arm64_linux:       "8790319fcbc8df889745bb7b43d970f31470d7098c65d6fe1f18710679004be4"
    sha256 cellar: :any,                 x86_64_linux:      "ef124756a90e43e24d074eb08a9d9ab5f918434b0aa3e199565e52ca89087dd9"
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
