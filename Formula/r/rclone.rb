class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.75.2.tar.gz"
  sha256 "68afd7f68c84bd978966feae2116339aa7bf454b39c573910c462e87c3774d5a"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "322e199865a0a9ebb1ac93d05966dcd2eaac66f40aefa88a7a96f2e5fbd61bd9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "45dd484b7d258b76f660b79050e0b6f61b3add2a8adf0bdb3fc56134fb7127e8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0b7a26544e84ab96abb69afc6f7db4dc10df64a1cf151b7c2f38434fe728168a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "6829bd3bdd0aef0c8020ba716f179c83898672950e7d2948c7fa7320d7d191ee"
    sha256 cellar: :any,                 x86_64_linux:      "7c076b2b7e06ef644d9a04e25376fbef9ee03a422737ac49b953888b16335598"
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
