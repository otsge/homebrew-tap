class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.25.0.tar.gz"
  sha256 "766e48423e79359ea31e41db9e5c289675947a7fcf2efdcedb726ac9d0da3784"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 arm64_tahoe:   "90f1a9a8f570f02d53482d2f61b344da44de232519cb77a8879a9c198c401b11"
    sha256 arm64_sequoia: "952aec59f1ebcb244630d1ba58bf1dca8b4aae9bb3d718d2ba6b17261ee9e0d9"
    sha256 arm64_sonoma:  "303129ec1e45c83c4ca24e71259fa9f387ed43f3e1e894c45a921aa3a80cb6f5"
    sha256 tahoe:         "3b50b274a540c6eed91787c8ec5496b61765e6033fb3b54a995d8628ec5b8a9a"
    sha256 sequoia:       "a123ed48fefdabda19debf4dad2e1c233221b3634a372d37d1eb24649c20bae9"
    sha256 arm64_linux:   "de73b838241dd31cb086ed4222f633b25ba42cefcec3099bf9ccae9b3f75db3b"
    sha256 x86_64_linux:  "329904ab18d227d24ff938e547afe129d72fe95662c43c01d646160c6ee1235e"
  end

  head do
    url "https://gitlab.com/gnuwget/wget.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "xz" => :build
  end

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
