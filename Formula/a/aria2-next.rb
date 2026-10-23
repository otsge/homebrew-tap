class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.9",
      revision: "55b33e5c012638ac1855d607ed734ac1980d8594"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "2752ddc4c27c112a5eb53b04097b1497e005a473e1b4defc0d90e64fc67a10cf"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "b354f941d72c02c495d3ea52d7759a4089f670fe3c139fb94db77376cffe3436"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a5d8116cbdafde984008cc424cff2a078993773d182a67417bd5a1ddc4381732"
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
