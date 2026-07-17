class CurlOpenssl4 < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  # Don't forget to update both instances of the version in the GitHub mirror URL.
  url "https://curl.se/download/curl-8.21.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_21_0/curl-8.21.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.21.0.tar.bz2"
  sha256 "ad6f2f94934b38e31e48272833c99b891d045b4565fe942a53fbd27bd3910e16"
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "2a0429ee72cebe07ba2abcaed7be811bdd8176a0347b51f245b89afd67632383"
    sha256 cellar: :any, arm64_sequoia: "b7fe3f4bb72d6d7e84d2b1e1a1e02ac3f75bbf7607329666cd5e3598fb8d25cc"
    sha256 cellar: :any, arm64_sonoma:  "889124410a71fc182d1849dc35733897bec6d1f6519686bf71cf9832be651f94"
    sha256 cellar: :any, tahoe:         "ac933ef50fec71ff4b9712460a24594867aee38acfe85282176400b38ddd2341"
    sha256 cellar: :any, sequoia:       "66afe2ab0bfd6d0ae44681fe29014d2be86ae06a09a515bc9fdd01737d7df8f1"
    sha256 cellar: :any, arm64_linux:   "45a5aa82f7b8ddf290179b128c317eb63bfbf41e73de5fcd4c9d84ab384c1188"
    sha256 cellar: :any, x86_64_linux:  "aa82ee5433136c1d694dfbbb59e290ab8ca000fff9caf98d494fab0421dcfc8d"
  end

  head do
    url "https://github.com/curl/curl.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :versioned_formula

  depends_on "pkgconf" => [:build, :test]
  depends_on "brotli"
  depends_on "c-ares"
  depends_on "libnghttp2"
  depends_on "libnghttp3"
  depends_on "openssl@4"
  depends_on "otsge/draft/libngtcp2"
  depends_on "otsge/draft/libssh2"
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "openldap"

  on_system :linux, macos: :monterey_or_older do
    depends_on "libidn2"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    tag_name = "curl-#{version.to_s.tr(".", "_")}"
    if build.stable? && stable.mirrors.grep(%r{\Ahttps?://(www\.)?github\.com/}).first.exclude?(tag_name)
      odie "Tag name #{tag_name} is not found in the GitHub mirror URL! " \
           "Please make sure the URL is correct."
    end

    # Use our `curl` formula with `wcurl`
    inreplace "scripts/wcurl", 'CMD="curl "', "CMD=\"#{opt_bin}/curl \""

    system "autoreconf", "--force", "--install", "--verbose" if build.head?

    args = %W[
      --disable-silent-rules
      --with-openssl=#{formula_opt_prefix("openssl@4")}
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-default-ssl-backend=openssl
      --with-libssh2
      --with-nghttp3
      --with-ngtcp2
      --without-libpsl
      --with-zsh-functions-dir=#{zsh_completion}
      --with-fish-functions-dir=#{fish_completion}
      --enable-ares
      --enable-ech
      --enable-httpsrr
      --enable-threaded-resolver
    ]

    args += if OS.mac?
      %w[
        --with-apple-sectrust
        --with-gssapi
      ]
    else
      ["--with-gssapi=#{formula_opt_prefix("krb5")}"]
    end

    args += if OS.mac? && MacOS.version >= :ventura
      %w[
        --with-apple-idn
        --without-libidn2
      ]
    else
      %w[
        --without-apple-idn
        --with-libidn2
      ]
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = testpath/"test.tar.gz"
    system bin/"curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    # Verify QUIC and HTTP3 support
    system bin/"curl", "--verbose", "--http3-only", "--head", "https://cloudflare-quic.com"

    # Check dependencies linked correctly
    curl_features = shell_output("#{bin}/curl-config --features").split("\n")
    %w[brotli ECH GSS-API HTTP2 HTTP3 HTTPSRR IDN libz SSL zstd].each do |feature|
      assert_includes curl_features, feature
    end
    curl_protocols = shell_output("#{bin}/curl-config --protocols").split("\n")
    %w[LDAPS SCP SFTP].each do |protocol|
      assert_includes curl_protocols, protocol
    end

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_path_exists testpath/"test.pem"
    assert_path_exists testpath/"certdata.txt"

    # ENV["PKG_CONFIG_PATH"] = lib/"pkgconfig"
    # ENV.append_path "PKG_CONFIG_PATH", Formula["zlib-ng-compat"].lib/"pkgconfig" unless OS.mac?
    # system "pkgconf", "--cflags", "libcurl"
  end
end
