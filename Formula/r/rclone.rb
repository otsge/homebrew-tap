class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.75.0.tar.gz"
  sha256 "1292c5fae9d10d6df3ea0c2ba96de42336e96e2e878729af1f02f86900434ee0"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0936055375c240929537460e67a55fbbcb48e14c59fe2f8fb86b3e6c0b157032"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4f60094e705eb13f8506f91f630197ae6b813216a88c49c3feadfd47c221553b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c7bb320ff830d5b895856f452e9d0ed76a0f42ec6290d80d30d7708824ba0520"
    sha256 cellar: :any_skip_relocation, tahoe:         "f922a67b6db8af0709f415bf4374a133f0419506786c761d76dbf58362f5a761"
    sha256 cellar: :any_skip_relocation, sequoia:       "49c48ec4905e59d62c6274368a5057f24de14899d29191376fefa0e8f3657a74"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "fb3d6122262b667ad792259aab4d90da7648723ff978408e4933e4bffabbbfb8"
    sha256 cellar: :any,                 x86_64_linux:  "5deed9f3ede5457b981e201a7d0641b3e7635d295c3bf29871a220310bafc49c"
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
