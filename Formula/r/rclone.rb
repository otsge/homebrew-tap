class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.4.tar.gz"
  sha256 "b8279a31a5249e4aecf04acff744ace4a2e3a169e4539a24aa67a9994f645d3b"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c6ce8e7509d208d5a8dceea58bd6d28a206e3b807f170ef1c4d317c6ea422ce0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e2e79450b4b9050f175d8c7f0bae8525e4828db808a34729f40ebdaa62bf1e1e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b8230e037585570ff04d3bd48207b85d4a9ab5b96343a6568c471c4be43c6e48"
    sha256 cellar: :any_skip_relocation, tahoe:         "b3585e0c294780a450c71d8ed11eb287478666e2b541863bb67f540536c0644d"
    sha256 cellar: :any_skip_relocation, sequoia:       "53f337e525d3bbda5712c4f0d494b5dff9f0350089db8c0eec64a0a323d99669"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "f1bb353465ab1986184824606537fb6446b14537e342dfbc41de49cd58218ef5"
    sha256 cellar: :any,                 x86_64_linux:  "b17d83a3ae6cdd968146ca9da8ae15f4b5f224958d13e2c63167eaba564e799b"
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
