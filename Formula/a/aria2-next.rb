class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.2",
      revision: "d518e90574e3b933e15aa70241bdc1f766a2dd14"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "f641be1a1dbfaec90086fcf950290c882ef9050e8d67237dd39efc3f96858ea6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "083af8f189f8fee5d3b130212732b5cc38d606441d3810c13512c6051ab7b1fb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "cb62017dc14ed1c002d24cfeb8d8939a2f74da80615b977e7550438c0b3bb4dd"
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
