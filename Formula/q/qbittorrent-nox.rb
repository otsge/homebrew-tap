class QbittorrentNox < Formula
  desc "Headless peer to peer Bitorrent client"
  homepage "https://www.qbittorrent.org/"
  url "https://github.com/qbittorrent/qBittorrent/archive/refs/tags/release-5.2.2.tar.gz"
  sha256 "177efdadcd66fa66c473e97ee8ed117ce33ccb9a0a25a0716b62245ce506d1d7"
  license "GPL-2.0-or-later"
  head "https://github.com/qbittorrent/qBittorrent.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "b92fd60531b77cc28d91e3cd3c50c14a63088c17e2b96b908108b6f6650f740f"
    sha256 cellar: :any, arm64_sequoia: "c5c9b6aa3a3161361df7aec9d43a23bfb2286aa36b1a23eb46d3268941e46a01"
    sha256 cellar: :any, arm64_sonoma:  "b5b97d032edfeb5e9c3cce60664ad6849e0302f3c24810185340a588a17acf8b"
    sha256 cellar: :any, tahoe:         "6cf6a915014f538af0d90fd2f7508f1ab618cc985657e9e2f5c05fca7f32381c"
    sha256 cellar: :any, sequoia:       "8c8f7fee909c70a62b1d8038549721989dbd323313932f0aff055d1027dc129b"
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
