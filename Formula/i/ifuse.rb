class Ifuse < Formula
  desc "FUSE module for iOS devices"
  homepage "https://libimobiledevice.org/"
  url "https://github.com/libimobiledevice/ifuse/releases/download/1.2.1/ifuse-1.2.1.tar.bz2"
  sha256 "9d490470ba6553f8052b385bb5330462e46fbe82131ebe65be47a1cc1c70e857"
  license "LGPL-2.1-or-later"

  head do
    url "https://github.com/libimobiledevice/ifuse.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "glib"
  depends_on "libimobiledevice"
  depends_on "libplist"

  on_linux do
    depends_on "libfuse"
  end

  def install
    if OS.mac?
      ENV.prepend_path "PKG_CONFIG_PATH", "/usr/local/lib/pkgconfig"
      ENV.prepend_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"

      fuse_prefix = Pathname("/usr/local/lib")
      fuse_pc = fuse_prefix/"pkgconfig/fuse3.pc"

      unless fuse_pc.exist?
        odie <<~EOS
          FUSE was not found.

          Install FUSE first with either:
            fuse-t:  brew install --cask 'otsge/keg/fuse-t'
            macfuse: brew install --cask 'macfuse'
          Expected pkg-config file:
            #{fuse_pc}
        EOS
      end
    end

    if build.head?
      # This file can be generated only if `.git` directory is present
      # Create it manually
      (buildpath/".tarball-version").write version.to_s
      inreplace "configure.ac", "fuse3 >= 3.0.0", "fuse3 >= 1.0.0" if OS.mac?
      inreplace "git-version-gen", " --dirty", ""
      inreplace "git-version-gen", "DIRTY=", "#DIRTY="

      system "./autogen.sh", *std_configure_args
    else
      inreplace "configure", "fuse3 >= 3.0.0", "fuse3 >= 1.0.0" if OS.mac?

      system "./configure", *std_configure_args
    end
    system "make", "install"
  end

  test do
    # Actual test of functionality requires osxfuse, so test for expected failure instead
    assert_match "ERROR: No device found!", shell_output("#{bin}/ifuse --list-apps", 1)
  end
end
