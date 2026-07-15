class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.5/forgejo-src-15.0.5.tar.gz"
  sha256 "1005e5c6f7340e0cd86a7b3f4c34ae5c353fc34d012b6c6613eecfeea3ec8f99"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "68d62b6224a216bb29a1e091b3a25879b947e0a0eb4eb432259ed1a8c9f3fc12"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "328ad776a0f0c19accb19a2a79885c8dbf299e2e4f006564c90dda29c4e74b81"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "cc8274c2bf898437b1577b2eb42eb2d048ee617f756280d118a235c385b6274d"
    sha256 cellar: :any_skip_relocation, tahoe:         "5b8ec3f1b707742df9211c9afb2f3d95b35d367e224f2c783dbf156097ad4c7f"
    sha256 cellar: :any_skip_relocation, sequoia:       "b08ee5d05e1c725836d34d2a3821a4058b7186f55e5cb87795c61285003588f6"
    sha256 cellar: :any,                 arm64_linux:   "6ea7db9ddf448e3a0e3a6fcd6e2846b67c6e655a28faec4aa0e0e043f5a06736"
    sha256 cellar: :any,                 x86_64_linux:  "f04cf27048f6596fbba6f0d13d867c270ab0941968a2b05530e5247c4572acbc"
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
