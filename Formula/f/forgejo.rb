class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.3/forgejo-src-16.0.3.tar.gz"
  sha256 "169df80055a819e3062eab365c384470ad34f71a0b921a58c3dcd1f838c10864"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "34aeef4b1b0e5167d635b681246ae965041f1821e6e26be9a22a1da4141300f4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0ff2702fff53d23725e7487245ff60be3b619820b30be0c51ada4053798882b5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "38e757a56b65ce62c7624f2925bee179bba3a9a666299819cfa65e682beea628"
    sha256 cellar: :any_skip_relocation, tahoe:         "ac8bc00ea1f27fdd068f29d3c29e8f535ec651cccd39d52aeb28ffbdcc2176b7"
    sha256 cellar: :any_skip_relocation, sequoia:       "01c40f0153c4084748bc1af171451da2233282cf2c0b94712fe2c416a772870a"
    sha256 cellar: :any,                 arm64_linux:   "ada9813d7d8793bb00dfeb535e9ffa6848243f05f8051af9c5912057ce056563"
    sha256 cellar: :any,                 x86_64_linux:  "6138dff9c52cb279822861b1ef654a0f670fc3271672739482ed79e9a2ebfaba"
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
