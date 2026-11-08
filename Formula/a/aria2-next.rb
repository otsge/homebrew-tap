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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d5d947861d915ee1d449410e5daff790a603f15aaff710a75a0b88707fa1ac0f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "364340b4755be7820fc749d39d19c6eee4aab9f5aa94938a57e642c4480db687"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "75388da37fbf9c36f75e16ead6a62735e118fbb9cb6540eac7fb6ae4a8c8231f"
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
