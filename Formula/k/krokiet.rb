class Krokiet < Formula
  desc "Duplicate file utility"
  homepage "https://github.com/qarmin/czkawka"
  url "https://github.com/qarmin/czkawka/archive/refs/tags/12.0.1.tar.gz"
  sha256 "0503f6969a2184fbe2b6b6d786a4ae1b50779f4ce62b57223d1407c70f500587"
  license all_of: ["MIT", "CC-BY-4.0"]
  head "https://github.com/qarmin/czkawka.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "2c9f3e949e669fd78ca88fbd519226692dc65f6ad245b33abce8b7aa4d7ca5f5"
    sha256 cellar: :any, arm64_sequoia: "3d397daffab11a7a4bd0d1025515cbaf5eda5215b04c4fe8ed4c9cd4f3999325"
    sha256 cellar: :any, arm64_sonoma:  "989fc5b62c4b5511dec2e9cbd505a5c3348e6ba9a5e1473553b3ab55dc1ea1f8"
    sha256 cellar: :any, tahoe:         "4593e6dc3eb96de0b6a0524891531f55cfe1e9fb0e0de6d41c89e261704bc360"
    sha256 cellar: :any, sequoia:       "5b50a439527571fbdc1c54ce52ba417805f095d0a75ef928bf1d8cc585af1430"
    sha256 cellar: :any, arm64_linux:   "ad5b6463f5c163683f8b47b45ce2b789c6f43f3845a40d371877346e7db27816"
    sha256 cellar: :any, x86_64_linux:  "75ea81e5c0d884b0dbf17cd8c88098e44829886e923b0c8592820220e6429db3"
  end

  depends_on "rust" => :build
  depends_on "dav1d"
  depends_on "ffmpeg"
  depends_on "libavif"
  depends_on "libheif"
  depends_on "libraw"
  depends_on "pkgconf"

  uses_from_macos "bzip2"

  on_linux do
    depends_on "fontconfig"
    depends_on "freetype"
  end

  def install
    inreplace "Cargo.toml", "#codegen-units ", "codegen-units "

    arg_cli = %w[heif libraw libavif]
    arg_gui = %w[winit_femtovg winit_skia_opengl winit_software femtovg_wgpu]

    if OS.mac?
      inreplace "Cargo.toml", '#lto = "fat"', 'lto = "thin"'
    else
      inreplace "Cargo.toml", "#lto = ", "lto = "
      arg_gui << "winit_skia_vulkan"
    end

    system "cargo", "install", *std_cargo_args(path: "czkawka_cli", features: arg_cli)
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "krokiet", features: arg_cli + arg_gui)
  end

  test do
    system bin/"czkawka_cli", "dup", "--directories", testpath, "--file-to-save", "results.txt"
    assert_match "Not found any duplicates", File.read("results.txt")

    assert_match version.to_s, shell_output("#{bin}/czkawka_cli --version")
  end
end
