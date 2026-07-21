class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.1/forgejo-src-16.0.1.tar.gz"
  sha256 "3699caf038f097cf01c1633d64df966e27916bcb5c46fcd0a5130c9debb858b2"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f74acca0b191be863c54c9d57aed63d74e148413ba6403cf75378e3f3c33aaa4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b4ae56dee328b705ec4645511f92b68c7a2b274e367ccce8915e39d7a5da6713"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c2ebc8e9c8a7640767b6b43ead5e34be3296f15b8f3438d20ac8f8bb952a7e5b"
    sha256 cellar: :any_skip_relocation, tahoe:         "3ae1adf59d8c80fbcc000284faffe1de5a4c548fde8c73b579421a34b0b46e0d"
    sha256 cellar: :any_skip_relocation, sequoia:       "3150a689794a6f19748e2e2a079efb2cae6414f5f25a80033bb0ff5fbb24b61d"
    sha256 cellar: :any,                 arm64_linux:   "1c7b527e125a5a80163cfd0c9813c1d8409f116264d7095f04f71cc18a1f9912"
    sha256 cellar: :any,                 x86_64_linux:  "7d62214abcf324dbb03bf1972eec8b6e2e07e3af99d56ced4557e542efaba864"
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
