class QbittorrentNox < Formula
  desc "Headless peer to peer Bitorrent client"
  homepage "https://www.qbittorrent.org/"
  url "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-5.2.3.tar.gz"
  sha256 "a5f540cdfb0053f0ce1a1c62ccd92d08214f16bcb2c512569ec54d81531e541f"
  license "GPL-2.0-or-later"
  revision 1
  head "https://github.com/qbittorrent/qBittorrent.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "faabea717eaebe5b96303dd27140e657a412bb4c579940039f5468396e3d6357"
    sha256 cellar: :any, arm64_sequoia: "d0de11f61879289b97562e28f052385ad078e84e925843f2e3c4967f83c3e2f9"
    sha256 cellar: :any, arm64_sonoma:  "1f83641b96eb0ac0c667a7195ba2f7f36358545d6f4f45462108a0925af23eb7"
    sha256 cellar: :any, tahoe:         "2a7f2efc53abf7b7d914c40f4518c20a54d358a9c2cbed12a10b500041248758"
    sha256 cellar: :any, sequoia:       "d5d9bb5956b8437359e4a3bec85c2174483b4214c61d7afc03f985efdf363991"
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
