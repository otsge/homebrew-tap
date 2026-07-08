class Krokiet < Formula
  desc "Duplicate file utility"
  homepage "https://github.com/qarmin/czkawka"
  url "https://github.com/qarmin/czkawka/archive/refs/tags/12.0.0.tar.gz"
  sha256 "cc5183c2ad251bc83d67dc6b12205a0d3d41a568ef89f16db27eb81f15c20e02"
  license all_of: ["MIT", "CC-BY-4.0"]
  head "https://github.com/qarmin/czkawka.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "972c93e2cd29f15e4098aa5a8fcbe590a99c928249c2d780f306eca00da67427"
    sha256 cellar: :any, arm64_sequoia: "51ca98152be9bebe301c3497f37188d7a9e55ffb74ec77efa7581fbbdc53430a"
    sha256 cellar: :any, arm64_sonoma:  "5f7e1279d356a33440167ff5946fe2eddfaaa34218c6c0988f8993382f2150ab"
    sha256 cellar: :any, tahoe:         "08bb883e8d98194035b9f3d92512579d1d39c669d01f0e4b5108e3b3e9a262c6"
    sha256 cellar: :any, sequoia:       "965424d621385c6ba16547f57a9777bd66b707ddf1e420c30d0ce30ab9a8b3a4"
    sha256 cellar: :any, arm64_linux:   "960ec1eb1f7ab9aa9472c678bb627e3e21174a4ef9774d49f8d8ae9dbe6e790b"
    sha256 cellar: :any, x86_64_linux:  "f5fd3e8d0bb498a5b1301851e5fe658935e1754af6d71313da1af0b7521a5381"
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
