class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v2.8.6",
      revision: "729af1187160f8d71985f51fd58c63a8826b7132"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0eb0b27faebae4a5b9b68f9b955f7b282fd32d35123c7cdaff7049e4586e02f2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "0c1a90efd24085968860d9c6ef4571292f703c686adb83f015c13b321641cdd4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "62a2a1b6d29caa949fafce01178fb9cf966e8f38ece249660853c9b4e353e7cc"
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
