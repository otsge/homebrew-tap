class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "85ee7660bb76ed9277573d2c856bcfebd3181b919edf3862e7f9e15d32097088"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e2c7f43d07380e5a3c5fcff2e66738f0f0cc692fb4eca3fa06b6e707e6f123f9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3fb4541c50d801c79048c1d973017a4a246845ac52df0a80ddd6fb304a91616a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "0b75a14acb5fd593a374c0c21f21bf7c878968132602255844ae343563662d03"
    sha256 cellar: :any_skip_relocation, tahoe:         "47b46966f46c7dd27214887c152cb94931e937cefe2e71561b0326bd8cead961"
    sha256 cellar: :any_skip_relocation, sequoia:       "3fe598f1f4de05d2e6061b9163e6143a5ed523b48c0ac481dad9bdaed41ed6a3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7cdbb60774f4726b6c737f70666b63b5a1dacea1687a35c5bd86a48b53c07126"
    sha256 cellar: :any,                 x86_64_linux:  "86d5ab9335447e3bb31610d8999f57a30d100cb3a9b6e12b2732d054d8525c1f"
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", *std_go_args(ldflags: "-s -w")
  end

  test do
    require "pty"
    require "expect"
    require "io/console"
    timeout = 30

    PTY.spawn("#{bin}/taproom --hide-columns Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Casks", timeout), "Expected cask loading message"
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
