class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.3.tar.gz"
  sha256 "3ba8bc7fb216f8f0307357ac67842467f453050468d5751e9269954819148568"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "90c58d3e1a97270fd457ff5bc2b7367170fdfc7ffda19a736beeaef84124a9b4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fc3f8a0bef99f1bbf2daa30b864f72bc8d08bc73a603337e7b950acc162c2874"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "86c930bae38ace124df7ee71dddd88a4159c13491e2916c4ca1daf591f38226a"
    sha256 cellar: :any_skip_relocation, tahoe:         "8a8f214b759691e126646104edd86fc6fe51f9ecde40e8e5ca4c74e703975780"
    sha256 cellar: :any_skip_relocation, sequoia:       "e1fd0332bcc333ac423b3ff20bae2af40ad054661a861a06df1702132e985836"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "ee7c8abba557cf14b896e7a237edfc07fb379f6da4d7a3a611bf9602589e3124"
    sha256 cellar: :any,                 x86_64_linux:  "de5aa0f0700b1ddc8b45efba2f5b6c5b1211583f2e4d3ddf41eae44ef9fd0e63"
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
