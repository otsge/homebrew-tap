class QbittorrentNox < Formula
  desc "Headless peer to peer Bitorrent client (libtorrent-rasterbar 2.0.x)"
  homepage "https://www.qbittorrent.org/"
  url "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-5.2.3.tar.gz"
  sha256 "a5f540cdfb0053f0ce1a1c62ccd92d08214f16bcb2c512569ec54d81531e541f"
  license "GPL-2.0-or-later"
  revision 2
  head "https://github.com/qbittorrent/qBittorrent.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 2
    sha256 cellar: :any, arm64_golden_gate: "7943321b27ea896b9534ae8b3bec2b097e74f2153a781351e6661dfd7932a536"
    sha256 cellar: :any, arm64_tahoe:       "279dcf667220c5764be105cdfb1a7da19179a3b4141f091208649714caf34a4b"
    sha256 cellar: :any, arm64_sequoia:     "9910662d18d73bc9d7532083a74b01243eb52537e6de210628772ba7113e584c"
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
