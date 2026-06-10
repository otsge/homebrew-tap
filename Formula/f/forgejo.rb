class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.3/forgejo-src-15.0.3.tar.gz"
  sha256 "39ac3023d1d6165a87d89bb44402ec4567327d952900d5522b92a3951b45db45"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7fe40b63eb267a6efe17bd459da477ce0b72e9d87b779ee0aa4bd0b3def70c68"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3e77326fe49feae52b8cc54622b9a85d97006f7d253e9e5ddf6257b63d86cab2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "62230c7efc9130f6716e0d9033c0e9f3bf653ad60d9a22af8848161c819d7089"
    sha256 cellar: :any_skip_relocation, tahoe:         "d44779c165b0b8eb4c99c6c4bf9a43a84714df01b2753ab71432ffda04f80ab9"
    sha256 cellar: :any_skip_relocation, sequoia:       "329bc584be96ff446e8b3963837989d2170c5a76b66523504b08cd2fd47dc7db"
    sha256 cellar: :any,                 arm64_linux:   "d3d7c4548a847ec82e35f4ad50f9623e3e8d38c222f4db64b91952e3564c08b8"
    sha256 cellar: :any,                 x86_64_linux:  "b4ded98b16e5f049ceaee22b2956ff86c9935f9569ffbe5aa58fcfc89c0cfe08"
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
