class Aria2Openssl4 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "ceaee09eabe1311afb3098963513a5624727012deb7267acf5584149c0ba3dfb"
    sha256 cellar: :any, arm64_sequoia: "244d5fdc8ece017b4e101b6b75b965c2b5a34d5c8b867fbf786c6961a5daa092"
    sha256 cellar: :any, arm64_sonoma:  "d02c23debe627b22529cab82879bba6df650461226ecb0ff68e14ad08d64951e"
    sha256 cellar: :any, tahoe:         "285be6cf8fb0fe7a349e864216843e0158c16c168edcec3a59d6ad0f8c535a95"
    sha256 cellar: :any, sequoia:       "6c0d63b86b7e280d6ee7ddc9303add9545339e455be4c9a7be408a97c1ffe3b8"
    sha256 cellar: :any, arm64_linux:   "82d272c92f2321bcb1593a59334966172ac1f20a476531f5bc0f40ee08279ff3"
    sha256 cellar: :any, x86_64_linux:  "88dd34097435ed18077a36307595084b3cb3e282a1e10cabdf0a7976dc752c72"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :versioned_formula

  depends_on "pkgconf" => :build
  depends_on "c-ares"
  depends_on "openssl@4"
  depends_on "otsge/draft/libssh2"
  depends_on "sqlite"

  uses_from_macos "libxml2"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "zlib-ng-compat"
  end

  patch :DATA

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

__END__
--- a/src/LibsslTLSSession.cc
+++ b/src/LibsslTLSSession.cc
@@ -279,17 +279,17 @@ int OpenSSLTLSSession::tlsConnect(const std::string& hostname,
           dnsNames.push_back(std::string(name, name + len));
         }
         else if (altName->type == GEN_IPADD) {
-          const unsigned char* ipAddr = altName->d.iPAddress->data;
+          auto ipAddr = ASN1_STRING_get0_data(altName->d.iPAddress);
           if (!ipAddr) {
             continue;
           }
-          size_t len = altName->d.iPAddress->length;
+          size_t len = ASN1_STRING_length(altName->d.iPAddress);
           ipAddrs.push_back(
               std::string(reinterpret_cast<const char*>(ipAddr), len));
         }
       }
     }
-    X509_NAME* subjectName = X509_get_subject_name(peerCert);
+    const X509_NAME* subjectName = X509_get_subject_name(peerCert);
     if (!subjectName) {
       handshakeErr = "could not get X509 name object from the certificate.";
       return TLS_ERR_ERROR;
@@ -301,7 +301,7 @@ int OpenSSLTLSSession::tlsConnect(const std::string& hostname,
       if (lastpos == -1) {
         break;
       }
-      X509_NAME_ENTRY* entry = X509_NAME_get_entry(subjectName, lastpos);
+      const X509_NAME_ENTRY* entry = X509_NAME_get_entry(subjectName, lastpos);
       unsigned char* out;
       int outlen = ASN1_STRING_to_UTF8(&out, X509_NAME_ENTRY_get_data(entry));
       if (outlen < 0) {
