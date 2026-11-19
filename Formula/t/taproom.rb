class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "626329f1bdcd3e982c690a90e1147fc995584c69583f20ba7dfb6cc72419760e"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "369a61167866161858e050ca353b5be767d657f1bf17130bd31d17cc116b446d"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7f18b85982d94abc739d9cf929785d1d643e0813fd6e075ae5d4f38f1588a3be"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "b23bbe97b7f3c201463eea1d1bab3fc113b01583ecd194f4e1e0ca99afb6ad20"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "4109b46ecdf060b46f2e84aa7c858ec7d1ba60c0686f2fd6647713a4c9a68ea5"
    sha256 cellar: :any,                 x86_64_linux:      "fc44aeee3f246ffa5d0213a76e274d6430685dab1e8872f6d43b0cd019f51675"
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
