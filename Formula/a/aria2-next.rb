class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.1.0",
      revision: "3092f6e22119d79c7f2bbac43031e7804cf28989"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "864f03b5b69e57220d87476389adb2ca99537234d4f0eb63837406140121cdea"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1bb05972e11e5aba98da823018229cc36b6c97c0666515502b3d19850480398e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "92981ec80d4e77200277c5d30f79d05d24e4318c3b5af5addb0d1f5ae02f1b06"
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
