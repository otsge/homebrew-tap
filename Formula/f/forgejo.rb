class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v16.0.4/forgejo-src-16.0.4.tar.gz"
  sha256 "13c5d34ff00cf24e8dc27d9b4df69d1e85263398c56ccab3e944ee8b0bb89ab2"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fafc620c47f5ddfb3710e0eb0eb3eb01343170b1dce669b8cf68019b3ca2735c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9e50b08ccb9e8d53f44658ea4af231404dafd79e24b5679959f71be855c89381"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "0e64d8243f7c839b412c367c332f13a9ea7a07a0475dd4c2a97a177532b82975"
    sha256 cellar: :any_skip_relocation, tahoe:         "dd3e4c5681af0ce7affdc68150d550325c64339585dcab716ce022dba725a569"
    sha256 cellar: :any_skip_relocation, sequoia:       "ef6131aae2df8c32d915ae466b88ff096df7da6af6d717fc3122b0e1ec30df7c"
    sha256 cellar: :any,                 arm64_linux:   "93a180b414d954746deb6ded99a571fc9ba24175d1b89bbf313985403433785b"
    sha256 cellar: :any,                 x86_64_linux:  "28c0503849ef8ab6278f9e881cfb642413d06844b1bb54b58e670878d26b2a78"
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
