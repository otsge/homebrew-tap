class QbittorrentNox < Formula
  desc "Headless peer to peer Bitorrent client"
  homepage "https://www.qbittorrent.org/"
  url "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-5.2.3.tar.gz"
  sha256 "a5f540cdfb0053f0ce1a1c62ccd92d08214f16bcb2c512569ec54d81531e541f"
  license "GPL-2.0-or-later"
  revision 2
  head "https://github.com/qbittorrent/qBittorrent.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "6a850a5832848d0556e63cc3b8bce842147ec4e2a193bf70208e614276de0d99"
    sha256 cellar: :any, arm64_sequoia: "af3acc380e9d483dec06e8775509d7d841f3d3e218be4fdc9e451f3d140f748b"
    sha256 cellar: :any, arm64_sonoma:  "f7d0c9c69d4adf73e5234983b264ac8d66b95cf3cba7c800002fc4c9feefea99"
    sha256 cellar: :any, tahoe:         "29e7c96de9bf35a246d2ebd6cf8733cb80ef4ad9aeac55e250f8d1088bbe6543"
    sha256 cellar: :any, sequoia:       "3bfc6f9a01930be3d75edb3df33e1caffad615d63c82dece2724035755b20fa5"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "qtdeclarative" => :build
  depends_on "qttools" => :build
  depends_on :macos
  depends_on "openssl@3"
  depends_on "otsge/draft/libtorrent-rasterbar@2.0"
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

  post_install_steps do
    run "/usr/bin/xattr", args: ["-cr", "{{libexec}}"]
  end

  service do
    run [opt_bin/"qbittorrent-nox"]
    keep_alive false
  end

  test do
    assert_predicate libexec/"qbittorrent-nox.app/Contents/MacOS/qbittorrent-nox", :executable?
  end
end
