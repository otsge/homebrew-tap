class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.5/forgejo-src-15.0.5.tar.gz"
  sha256 "1005e5c6f7340e0cd86a7b3f4c34ae5c353fc34d012b6c6613eecfeea3ec8f99"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "806822c2ea5b0e10eb56d20fa2441f25f54419415789668577ae7530e8b6c866"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8a5732000fe0cac589f410b610b73c32758322305d85a6deb496664d2b36e52c"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "8a8db1a6025e2c17d145d7a9afc336a088a792eaf5bdc1299e12280cd541be3b"
    sha256 cellar: :any_skip_relocation, tahoe:         "767c1add5460811f31f1e705cdaf14a902cef7de133ba356b4c1ef3e1cf36761"
    sha256 cellar: :any_skip_relocation, sequoia:       "ee05fcff846855c1a377652b315d26d535c81b00ccb9324e1cb16bcb9556baf4"
    sha256 cellar: :any,                 arm64_linux:   "1a9152c89ec961febf1a1e04b74436deee35a3356bcfd1d719648e5616ee064d"
    sha256 cellar: :any,                 x86_64_linux:  "ae6090db92550218a20ec9ca67943cef2c972d9438db16b239f13e6bd9261f1f"
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
