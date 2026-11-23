class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.1.2",
      revision: "2a13a664edb5314d86bfd7d488305266be6688e8"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "709a515a66f4745e1ac3a2b6c5752184e7c157073d0059d5c6008c224cc15ef0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a49815cfcae3140438bf280df05a5341a6425fc24e147215e3cb065a379e94a9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4464b6a37b3ad7446370f2a3649a4d5c8a670c93d87671038bc60cb6f5307dee"
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
