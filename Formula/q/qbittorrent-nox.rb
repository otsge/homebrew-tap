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
    sha256 cellar: :any, arm64_tahoe:   "17167d91941604eda57fcafe720bd2e129b9233feb3fe34a89c8a522f7fe8f0c"
    sha256 cellar: :any, arm64_sequoia: "190a64a379988fd647a660b6861874ca193c6e3bf9d44f7cbf97441090fa67b2"
    sha256 cellar: :any, arm64_sonoma:  "591e440747115320cdb9792f4e0d0ee9169cfaefd515fdc7718da8c1bfd25b3c"
    sha256 cellar: :any, tahoe:         "16aa1e2fd5c105b81fe563ab64cb5f2001ad45f6a8c44c845088ca1497a82511"
    sha256 cellar: :any, sequoia:       "37a47c8f2df85e1596ab8ccbaa1caf6c524d0471dc8105a8cc934459fab4c452"
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
