class WgetOpenssl4 < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.25.0.tar.gz"
  sha256 "766e48423e79359ea31e41db9e5c289675947a7fcf2efdcedb726ac9d0da3784"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 arm64_tahoe:   "c6f73915a7e8cf6079f7838c01b723cf229be90a902bd7f2aaae6441b583f515"
    sha256 arm64_sequoia: "332e2e6257bcca76ba4b14a27533d29f4549373f14dd9fc0debc03935661d3f1"
    sha256 arm64_sonoma:  "6cc5f23d80aa936c2bfd2e911a3ee8fc04f803987844c6997c53c7ceb2b8149e"
    sha256 tahoe:         "f773d278a7b1b715ddc25ecca3eb3ea8070341e552ec1358c115598ee3de51b6"
    sha256 sequoia:       "f6378b46ea97ed756598b8549831ca8ce1b94e6ad9aa343f1f4cf1804b1ab46c"
    sha256 arm64_linux:   "1ffa47aae3881180e3c771a68e6761d3fec5ffe5fee9d80dd3de781517c1bad0"
    sha256 x86_64_linux:  "76f49de13d4e1a9fe098e6a565d4df15095c54d629e938d1b5a572af9ac535d0"
  end

  head do
    url "https://gitlab.com/gnuwget/wget.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "xz" => :build
  end

  keg_only :versioned_formula

  depends_on "pkgconf" => :build
  depends_on "libidn2"
  depends_on "libmetalink"
  depends_on "otsge/draft/openssl@4"

  on_macos do
    depends_on "gettext"
    depends_on "libunistring"
  end

  on_linux do
    depends_on "util-linux"
    depends_on "zlib-ng-compat"
  end

  def install
    inreplace "src/openssl.c", "#ifndef OPENSSL_NO_SSL3_METHOD",
              "#if !defined OPENSSL_NO_SSL3_METHOD && OPENSSL_VERSION_NUMBER < 0x40000000L"

    system "./bootstrap", "--skip-po" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--with-ssl=openssl",
                          "--with-libssl-prefix=#{Formula["openssl@4"].opt_prefix}",
                          "--with-metalink",
                          "--disable-pcre",
                          "--disable-pcre2",
                          "--without-libpsl",
                          "--without-included-regex"
    system "make", "install"
  end

  test do
    system bin/"wget", "-O", File::NULL, "https://google.com"
  end
end
