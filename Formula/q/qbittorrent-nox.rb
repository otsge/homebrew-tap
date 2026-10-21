class QbittorrentNox < Formula
  desc "Headless peer to peer Bitorrent client (libtorrent-rasterbar 2.0.x)"
  homepage "https://www.qbittorrent.org/"
  url "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-5.3.0.tar.gz"
  sha256 "dcb5273496117ebf264fc1fc7936de8707374f07dcee0805228ac5adb403a465"
  license "GPL-2.0-or-later"
  head "https://github.com/qbittorrent/qBittorrent.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_golden_gate: "8b8af0b253d337dc2d0a7360247e575553ade4f5a8e2d4ef18be4e1a7e496600"
    sha256 cellar: :any, arm64_tahoe:       "8a43284c7ccb1a8e8c146ac1791a1465e655f9745ea5d987975c57a69405a15c"
    sha256 cellar: :any, arm64_sequoia:     "21212d96be3dd3b253e872465b29caf46e339b8675693d4db2f80dfb85238fb4"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "qtdeclarative" => :build
  depends_on "qttools" => :build
  depends_on :macos
  depends_on "openssl@4"
  depends_on "otsge/draft/libtorrent-rasterbar@2.0"
  depends_on "qtbase"

  uses_from_macos "zlib"

  deny_network_access!

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
