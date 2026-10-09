class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.75.2.tar.gz"
  sha256 "68afd7f68c84bd978966feae2116339aa7bf454b39c573910c462e87c3774d5a"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f15bc594ae5a1b0994c9dfd1f83aa847b4ea049556b9a2ed9763104a2622c453"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c6e966eb0b9e5b0f763cb2a7925fb03488ea1f7787cfc57c083e8e698fc93285"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e0ee4d6c4b58dba6ddf8ad06dc14d80c6f717754a8d0656e88b50d9d7b9268c4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "129906ccc1d0e058128aa56cc56fe017faccd0874ed5ae609794772920e85199"
    sha256 cellar: :any,                 x86_64_linux:      "8ac84c49bf53a254338d079504861ee9370ec7557e6fe829951800e3becfacd0"
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
