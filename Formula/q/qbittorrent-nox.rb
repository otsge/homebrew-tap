class QbittorrentNox < Formula
  desc "Headless peer to peer Bitorrent client"
  homepage "https://www.qbittorrent.org/"
  url "https://github.com/qbittorrent/qBittorrent/releases/download/release-5.2.1/qbittorrent-5.2.1.tar.xz"
  sha256 "becd0878802d4bc977381a41d8496d73ef64d543ba576be5f65fd3ad988ee8fe"
  license "GPL-2.0-or-later"
  head "https://github.com/qbittorrent/qBittorrent.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:[._]\d+)+)$/i)
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "d74870df8dfcb9a540bef34f6ad7f6cb4a3e50191404fb2620348d7e4ba5d468"
    sha256 cellar: :any, arm64_sequoia: "cc33f94a7682352f22bb1b3ce97c185ab22d8cb7c40bd45ddaf53c6d4a33c4aa"
    sha256 cellar: :any, arm64_sonoma:  "4215f4e0c3d6a62b4f9e0693c98ae6c76eb934163a2ea9242abb0123728a5b5a"
    sha256 cellar: :any, tahoe:         "e1a2dec4d34d9f14a094c8fcabb6ff698dba987a624969fa2e0d501883bbf5e4"
    sha256 cellar: :any, sequoia:       "f94fcb2612c2b13080791d364f442cf71f1286ceb7196ac558bb6358e2c40f91"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "qtdeclarative" => :build
  depends_on "qttools" => :build
  depends_on "libtorrent-rasterbar"
  depends_on :macos
  depends_on "openssl@3"
  depends_on "qtbase"

  uses_from_macos "zlib"

  def install
    inreplace "dist/mac/qt.conf", "PlugIns", "#{HOMEBREW_PREFIX}/share/qt/plugins"

    ENV["QT_PLUGIN_PATH"] = "/opt/homebrew/share/qt/plugins"
    ENV["QML2_IMPORT_PATH"] = "/opt/homebrew/share/qt/qml"

    args = %W[
      -DCMAKE_CXX_STANDARD=23
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
      -DVERBOSE_CONFIGURE=ON
      -DCMAKE_VERBOSE_MAKEFILE=ON
      -DBOOST_ROOT=#{Formula["boost"].lib}/cmake
      -DSTACKTRACE=OFF
      -DGUI=OFF
      -DDBUS=OFF
      -GNinja
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args(install_prefix: libexec)
    system "cmake", "--build", "build", "--target", "qbt_update_translations"
    system "cmake", "--build", "build"
    system "strip", "build/qbittorrent-nox.app/Contents/MacOS/qbittorrent-nox"
    system "cmake", "--install", "build"
    bin.write_exec_script "#{libexec}/qbittorrent-nox.app/Contents/MacOS/qbittorrent-nox"
  end

  def post_install
    system "xattr", "-cr", libexec.to_s
  end

  service do
    run [opt_bin/"qbittorrent-nox"]
    keep_alive false
  end

  test do
    assert_predicate libexec/"qbittorrent-nox.app/Contents/MacOS/qbittorrent-nox", :executable?
  end
end
