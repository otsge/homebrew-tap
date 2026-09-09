class Krokiet < Formula
  desc "Duplicate file utility"
  homepage "https://github.com/qarmin/czkawka"
  url "https://github.com/qarmin/czkawka/archive/refs/tags/12.0.2.tar.gz"
  sha256 "b9e1722ac2625aa0c5861eac6499cafe9e4e7cc0bc9a429c8c3ad6c1e8cd68f1"
  license all_of: ["MIT", "CC-BY-4.0"]
  head "https://github.com/qarmin/czkawka.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "4d3ed73622836d4937208a4fc229e5a332a11c95faa4f67a2f188ea551a6703e"
    sha256 cellar: :any, arm64_sequoia: "94115499b96373af49e242f610e1ebe678b43024108480b8385c83aa87a36a1f"
    sha256 cellar: :any, arm64_sonoma:  "595800904d28cc66297cc53a952275f780adc7a7483f703802c9bd14ecbbd415"
    sha256 cellar: :any, arm64_linux:   "0151f923d779936ccac0e9c284222481850fd3049a4d3bcc6b897f2c3257ba9d"
    sha256 cellar: :any, x86_64_linux:  "07152f458014073ad387853951fbee2d6339525c0170ee9bd55b9e7057dc2957"
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
