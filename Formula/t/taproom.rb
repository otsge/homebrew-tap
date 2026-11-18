class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "66c8c6ab96f08382b95c3f8bebae15915c0bc1678bcecb4811cdab6f21063e31"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "96eee4987c42060b7bb3ac3a489cef43191a416362bebb5aef26eebfad35f093"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c5ea3b1971af44c572a5ed732fc9dff852e0fc1ca311baf9fcbeed0116c1dae8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "b5d44848924f94f9d9310e4c6de51100c9a2c3413615b3064fcd8563205b65e0"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "f6b60b8bf2cf2f049e65f8ae71acc4337e0e8b60c9710e6224b6a4796dd58a7e"
    sha256 cellar: :any,                 x86_64_linux:      "0adee36cc1b12f967eb8e9212ff0780c347199d7b3a9457e7e1d42825d4361e1"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", "-trimpath", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/taproom --version")

    require "pty"
    require "expect"

    # taproom is a full-screen Homebrew TUI. Launch it in a pseudo-terminal and
    # confirm it boots and renders its data-loading screen, then quit cleanly.
    # The loading task labels are drawn before any network response, so this
    # exercises the real UI without depending on network access in CI.
    PTY.spawn(bin/"taproom", "--hide-columns", "Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Packages", 30), "taproom did not render its loading screen"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
