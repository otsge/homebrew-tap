class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.8",
      revision: "fa9f2f2eda8d73afa611cd18cec0a0a4dba0da46"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "6bb058c1b299d7f4b075aae999bdbca0e6f64174bb111b589aa2e6bbb167d4da"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "16bb6fdff840c8daedc1974216c7e5c975d8363b2ef7e978aa81fcc42b8cc858"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2ed100c981a8a7b281b4996e11103b9e24f1a0b562e541ee875d77f52f6786c0"
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
