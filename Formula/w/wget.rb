class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/wget/wget-1.25.0.tar.gz"
  sha256 "766e48423e79359ea31e41db9e5c289675947a7fcf2efdcedb726ac9d0da3784"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 arm64_tahoe:   "965a8cc89cbf1e0c02479bfba9df18a106567dcab2251a9260a793bb55044cd0"
    sha256 arm64_sequoia: "8ce3f231eec676cce00ff0e4d343cae5c5249520bbef9e0f51a08b74abfaa326"
    sha256 arm64_sonoma:  "f79aade0497c52a6fe4b6ddaca51d52ce4056261a7ebd52b5959cdb6219cce5a"
    sha256 tahoe:         "bbfc1f16cad485ba8aef94bdbb3a6a4693983c3f5e5b369600343d5dd3949088"
    sha256 sequoia:       "8646b54ab20587feae01c2d32cc47528eaa54bda8349126a4999f7a5e12d854b"
    sha256 arm64_linux:   "a26876a479ab29863f478d2d3ef3a4a14ca7f0966cfd169f2a0f800211358983"
    sha256 x86_64_linux:  "02638c9b20c60d7f779bdf603fa068a6acfdc22119e75300d2ccc81d7d8a3c9b"
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
  depends_on "openssl@3"

  on_macos do
    depends_on "gettext"
    depends_on "libunistring"
  end

  on_linux do
    depends_on "util-linux"
    depends_on "zlib-ng-compat"
  end

  def install
    system "./bootstrap", "--skip-po" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--with-ssl=openssl",
                          "--with-libssl-prefix=#{Formula["openssl@3"].opt_prefix}",
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
