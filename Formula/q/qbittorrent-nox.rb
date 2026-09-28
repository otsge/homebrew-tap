class QbittorrentNox < Formula
  desc "Headless peer to peer Bitorrent client (libtorrent-rasterbar 2.0.x)"
  homepage "https://www.qbittorrent.org/"
  url "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-5.2.4.tar.gz"
  sha256 "226a6ad1aa7810fcbfa58b0d28b14feb8e207726cbe774d4d267ce769c19dd6c"
  license "GPL-2.0-or-later"
  head "https://github.com/qbittorrent/qBittorrent.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_golden_gate: "658255be7864479d7b870e88c6a67c50769847726a8ff4d01658a18917e53f22"
    sha256 cellar: :any, arm64_tahoe:       "a5234ff5855ee1354c909117b97d655a7156ca0aa6978b5161b7f576f026121c"
    sha256 cellar: :any, arm64_sequoia:     "00199369d0edb0aa16e126869a63db2b303c669477cb9da335735b4b2cf02e97"
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
