class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.76.0.tar.gz"
  sha256 "8cb7e5d576fe9a3aef8b1a0785e2ffc6c1953f8ed109f42000b0b86718f6628b"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b05d19dcb2090b8a6173a2e21c06f05553ce9b3b8c0928d76a1dfefcc9e1c92a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f41018a2933bfa1201370c8ca1f106a633bdcbbb0b279cbba44faafd75cb8f51"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "df2f48d8e3abb0604f21004cee2ad22a60a0dd402fe81fa17eca2e63e9210c31"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d16e7fd1e9bc5c214f55dfdb80eb1480e71fe2edc1b77f23783437fcd6089db2"
    sha256 cellar: :any,                 x86_64_linux:      "c5fea0f6bd18bc43b890185cb8cd35e4e026a361f0865126396c9f586ab10565"
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

    cd "cmd/genautocomplete" do
      inreplace "genautocomplete_bash.go", "if len(args) > 0 ", "if len(args) >= 0 "
      inreplace "genautocomplete_bash.go", 'if args[0] == "-" ', 'if len(args) == 0 || args[0] == "-" '
      inreplace "genautocomplete_fish.go", "if len(args) > 0 ", "if len(args) >= 0 "
      inreplace "genautocomplete_fish.go", 'if args[0] == "-" ', 'if len(args) == 0 || args[0] == "-" '
      inreplace "genautocomplete_zsh.go", "if len(args) > 0 ", "if len(args) >= 0 "
      inreplace "genautocomplete_zsh.go", 'if args[0] == "-" ', 'if len(args) == 0 || args[0] == "-" '
    end

    system "make", "GOTAGS=cmount"
    man1.install "rclone.1"

    generate_completions_from_executable(bin/"rclone", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
