class Sshfs < Formula
  env :std

  desc "SSH based file system client built against FUSE-T's installed libfuse3"
  homepage "https://github.com/macos-fuse-t/sshfs"
  url "https://github.com/macos-fuse-t/sshfs/archive/cebbdd331199bf39b0566db236e3d47bfa27ea19.tar.gz"
  version "2026.05.12-cebbdd3"
  sha256 "16a398718194d03f890d4dec5b4c896f98abb10411cfc82dc37f8cf1d143a386"
  license "GPL-2.0-or-later"
  head "https://github.com/macos-fuse-t/sshfs.git", branch: "libfuse3"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "e49610b006fee1676d05c942ea2fd2f2e1dca73083b67ae55758228190984663"
    sha256 cellar: :any, arm64_sequoia: "2619c076dc92cbb4982ce90f7cbc98376ea09374f66b16317a3f4601c188aee3"
    sha256 cellar: :any, arm64_sonoma:  "3d0fdc4dcb076e8ab7f69a68bd02e2aeb2f127b177223fd936ed11a2786be22f"
    sha256 cellar: :any, tahoe:         "d067dcd997b300a301befa4fb76236fa71efa4f2aa1c844f8390c9a3bfb0ec5e"
    sha256 cellar: :any, sequoia:       "a4be10e5d76a160b0930ee97d990bcac5c9ac7d584012840bfefc3ac971d547c"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "glib"
  depends_on :macos

  def install
    fuse_t_prefix = Pathname("/Library/Application Support/fuse-t")
    fuse3_pc = fuse_t_prefix/"pkgconfig/fuse3.pc"

    unless fuse3_pc.exist?
      odie <<~EOS
        fuse-t with libfuse3 was not found.

        Install fuse-t first:
          brew install --cask 'otsge/keg/fuse-t'

        Expected pkg-config file:
          #{fuse3_pc}
      EOS
    end

    ENV["PKG_CONFIG"] = Formula["pkgconf"].opt_bin/"pkg-config"
    ENV.prepend_path "PATH", Formula["pkgconf"].opt_bin
    ENV.prepend_path "PKG_CONFIG_PATH", fuse3_pc.dirname
    ENV.append "LDFLAGS", "-Wl,-rpath,/usr/local/lib"

    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    sbin.install_symlink bin/"sshfs" => "mount.sshfs"
    sbin.install_symlink bin/"sshfs" => "mount.fuse.sshfs"
  end

  test do
    assert_match "SSHFS version", shell_output("#{bin}/sshfs -V 2>&1")
  end
end
