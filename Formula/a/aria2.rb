class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "c56aa9aaa46fa2495ab4edad14251868867b5d4568793f5b4ede9c081a4d9a7f"
    sha256 cellar: :any, arm64_sequoia: "3ac6b4589121acb5c2ef0100025d292591a733ec107ea509b3fbdc00c3e9ad06"
    sha256 cellar: :any, arm64_sonoma:  "351ef02daddf64460df986e528c541a0283814ed0b544dca50bc56d5bc4da2a1"
    sha256 cellar: :any, tahoe:         "9691265ad50785d947faac19afe689bd1e24f356a5bb32e7d047e4f500ca9c34"
    sha256 cellar: :any, sequoia:       "23ec261f88c87faccd119a61270799183ce6af06824487052c0fd5b157498eed"
    sha256 cellar: :any, arm64_linux:   "fd2e2a47c5ff73b1fa0ac0e96ae356ade292c09722fe7270c5b4b32a432f2f7b"
    sha256 cellar: :any, x86_64_linux:  "e993f98d48272ce77b4bd4b5aa8a206d5a1e710803d83f8b85757ef6d877e33a"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "c-ares"
  depends_on "otsge/draft/libssh2"
  depends_on "otsge/draft/openssl@4"
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
