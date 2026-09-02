class CurlOpenssl4 < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.se"
  # Don't forget to update both instances of the version in the GitHub mirror URL.
  url "https://curl.se/download/curl-8.22.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_22_0/curl-8.22.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.22.0.tar.bz2"
  sha256 "5d956a6a22b3c279f50c421ee5d3c9e9d660cb6f115dcf881b579e952130549c"
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "7d0c2ce22bf0149a69364689c3c15b44639af32a423ae396e867f6fb3c97b718"
    sha256 cellar: :any, arm64_sequoia: "05fc953ea119a8e8f16e56b83221509dceb6552cbd6208a5e03a5802a06190d1"
    sha256 cellar: :any, arm64_sonoma:  "5a7930fb8d18ea4435329eb254660e0306273f5e6a0984ed0312a02b929ae12b"
    sha256 cellar: :any, tahoe:         "e960b8af6d72557e36a794cc9e0c481edae1f172f2108d65ac34bf6682ba4e06"
    sha256 cellar: :any, sequoia:       "7017cbfc1cd3b877e123094a3481f2672b4de510bd83ced2085439b88bd6d689"
    sha256 cellar: :any, arm64_linux:   "990ce7e6aad73a6f410ff390e550fa0d5bbd450c111a1bf081e8af650943128b"
    sha256 cellar: :any, x86_64_linux:  "c48da84e4011e629b07f7b624f46e7c143ed4c17ac5d96c024e0d33dc6765e18"
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
