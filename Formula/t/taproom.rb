class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "80609d839488c34c8bf870b70430955fa600266fda16298c79a6c48c529404f0"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "cb006ec2191b2b159b13e687c7cc55875fdbfa6d8714bb6bd0650352f61633b6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a418613153ce5b194dba95a9273c0a56accf2c548d0648753466ea9be4e26a30"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "3ff297cb40f09b2f6738ce9cfb37e6ca95b3159684e397930d833b1745ceecf4"
    sha256 cellar: :any_skip_relocation, tahoe:         "0c3bf142c44cf2abc42e9e0b0bfb68808b5e019ef755cb5e3be3141680f04dd2"
    sha256 cellar: :any_skip_relocation, sequoia:       "fa5eedcf6e5cbe564fb0626b6f57d82b8235319e91ca489a409604d3f3492f54"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "00951b9c4fc22135734ef1a367eb4d51d23dbe86b2e0ba7b8e42f231bff71c5b"
    sha256 cellar: :any,                 x86_64_linux:  "bdec5de8239eaf9fa3efd9f2c141e461df98de572419528b53ba5fbb28d1be44"
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
