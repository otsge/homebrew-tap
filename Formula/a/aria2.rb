class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "7d72af35dbbd7af3adbfbb72ea650aa8718af5f012c77772e74fefb8697a993c"
    sha256 cellar: :any, arm64_sequoia: "1c777342d9ca3c3a359cad121f843be03c5ba904f6be334088739c52548dddd4"
    sha256 cellar: :any, arm64_sonoma:  "bcf97564031afdc39278a822c1336be128a505ee93451933708fc57f2c9609a8"
    sha256 cellar: :any, tahoe:         "50fb313e3ade72b7fe22fc4916f4bae70f0edaf21040926847af34862b7033aa"
    sha256 cellar: :any, sequoia:       "d162be658898a719f3ec97a72f503a19319d743ff15a1af28ae6e6d000cb2369"
    sha256 cellar: :any, arm64_linux:   "af086cb7437c2319d93b28cc782e88f0fd1afe8b10d0a023c381c902ad688851"
    sha256 cellar: :any, x86_64_linux:  "5a6522bdefcae92ab832d7a2a9145f73ef6dc44dd410f607c6d433838d6f7d8e"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "c-ares"
  depends_on "libssh2"
  depends_on "openssl@3"
  depends_on "sqlite"

  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    ENV.cxx11
    ENV.append "LIBS", "-framework Security" if OS.mac?

    if build.head?
      ENV.append_to_cflags "-march=native -O3 -pipe -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %w[
      --disable-silent-rules
      --disable-nls
      --with-libssh2
      --without-gnutls
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
      --without-appletls
      --with-openssl
    ]

    system "./configure", *args, *std_configure_args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system bin/"aria2c", "https://brew.sh/"
    assert_path_exists testpath/"index.html", "Failed to create index.html!"
  end
end
