class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.1/forgejo-src-16.0.1.tar.gz"
  sha256 "3699caf038f097cf01c1633d64df966e27916bcb5c46fcd0a5130c9debb858b2"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2b25adb328ae29eea46402fd12b1033a2087261e72373fbc0dcca7ac4526f425"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a5a7417151645e05700ad4a7480a834a1b2b757114db5a0ccbbffcbad384e403"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "93194f7b62007a8a4f60542ee3dfd60d4e2c06ccb96f4b42b766217035cc0edc"
    sha256 cellar: :any_skip_relocation, tahoe:         "2a81fbe5f04cac3f97c3bae8abfa804c21ae8e4032ea10eaf961a858bcadb4ab"
    sha256 cellar: :any_skip_relocation, sequoia:       "87b4eebc37de65ce8aeb58f5205ac3fc7f598464bd8412ac824e3925684870bf"
    sha256 cellar: :any,                 arm64_linux:   "3b8e9b5b8cb0588f474734d87a1a0fd42f65b737174fd648287882ed4b2a0a65"
    sha256 cellar: :any,                 x86_64_linux:  "3e62812c85fa0d04754f3cd0e20e25315f23d38876c661841582057086ee993c"
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
