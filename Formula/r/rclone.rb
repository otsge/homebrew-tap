class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.75.1.tar.gz"
  sha256 "fcc9351ab3976c73b4824cf7919f98f911f2442a606e2910fc2bd562111da220"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0d1262fbf14bbe42f67039e01ecbc0fce76a68869c702f495fade92759e7fc7c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fef6a0547effb9883ce9ecb35aea795539639fe9b01edf4b91de7f1fb0e9801f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fc6a448eb273b97b00918ff0358a95a7497677d6052a846303e567cb1a2dafd0"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7b11a377bffef07a64f608dbfa009f1672c61fc8cd4f5e1f6d8ea8583b3fe02a"
    sha256 cellar: :any,                 x86_64_linux:  "ebd93d3ac396782e17d1963258851c1eae92f985ad922f5d0acbe112c1baee82"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = buildpath/".brew_home/go_mod_cache/pkg/mod"

    if OS.mac?
      fuse_prefix = Pathname("/usr/local/lib")
      fuse_pc = fuse_prefix/"pkgconfig/fuse.pc"

      unless fuse_pc.exist?
        odie <<~EOS
          FUSE was not found.

          Install FUSE first with either:
            fuse-t:  brew install --cask 'otsge/keg/fuse-t'
            macfuse: brew install --cask 'macfuse'
          Expected pkg-config file:
            #{fuse_pc}
        EOS
      end
    end

    system "make", "GOTAGS=cmount"
    man1.install "rclone.1"
    system bin/"rclone", "genautocomplete", "bash", "rclone.bash"
    system bin/"rclone", "genautocomplete", "zsh", "_rclone"
    system bin/"rclone", "genautocomplete", "fish", "rclone.fish"
    bash_completion.install "rclone.bash" => "rclone"
    zsh_completion.install "_rclone"
    fish_completion.install "rclone.fish"
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
