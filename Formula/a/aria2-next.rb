class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.4",
      revision: "ff005332c1965983fa8f1283a520169dd17be2d1"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8264cd15e0315de0b52fbfafe765d8deeff3bfdf1365d8b334b2e5d027d18025"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7f9dce994c5e1ff377e700262a217be509a46e6dd65526271d86c78113e25868"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a229389f802d41ce424a007ac1229d1e080b6c7ff947da678da82750394b3826"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on :macos

  uses_from_macos "perl" => :build

  allow_network_access! :build

  def install
    target_processor = Hardware::CPU.intel? ? "x86_64" : "arm64"
    ENV["TARGET_PROCESSOR"] = target_processor.to_s

    system "./packaging/scripts/build-release", "macos"
    bin.install "build/release/aria2-next"
  end

  test do
    system bin/"aria2-next", "-v"
  end
end
