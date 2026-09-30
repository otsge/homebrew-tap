class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v2.8.3",
      revision: "f58a2d9463b3b549ca19039b055df1448e1b8c46"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "77395b6096f7aeb55fe4aa18121f9652cf8ad694116cf023fa10e8ead326a97f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "27ab732349c9ef8e0191e3c1c873ec47b82e9976ddc06d96efa2d8df8d11ecc6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "defe78ed89e5889bbc7178fb8ea3b99cbabc01f4f1d04d92c6a83134dfb8290f"
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
