class WgetOpenssl4 < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.25.0.tar.gz"
  sha256 "766e48423e79359ea31e41db9e5c289675947a7fcf2efdcedb726ac9d0da3784"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 arm64_tahoe:   "a5cdb77c9c174aaa5a886b0af59270397db9ef10f71c848dbbf4d2e2d65f2393"
    sha256 arm64_sequoia: "7572974aab702aecaa837fd1e3bd23ac31997978d0baa9edbd0c29b170b482cb"
    sha256 arm64_sonoma:  "493a74f107859ffc94bf4162c2afc321c372b680415511122f2cf04f40ceb2c8"
    sha256 tahoe:         "73502377267078fe9efbd91b5ad70fc5d9c62e2e8e6dbe99bddc01a2abd10495"
    sha256 sequoia:       "ec175691e4d6e4676d05db2cff9b792c727b50a06ff782a2376d3edcd90c1715"
    sha256 arm64_linux:   "54a25174c7a2a2635f460a6df2afe342c67c08eeef9b2c728cf850a17f70f42b"
    sha256 x86_64_linux:  "063e18d85b23ec6c337cf8c8c4441d58f28c4a9e0d16a4418ab4002c073d3922"
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
  depends_on "openssl@4"

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
                          "--with-libssl-prefix=#{formula_opt_prefix("openssl@4")}",
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
