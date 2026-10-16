class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.5",
      revision: "e0cf6349196c83e3b7527b480d47f60389ea0964"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "65adf86193d96ec2aa5807fc73934c53b7085f7b6df8e4799f3ac1e148afc524"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "36b362c0e47384a4b277886bc1957f27fafe016614d1ce7b9cf84ca9d832aad2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0c8bb44bf040454b389b35ef84f6a1c874696c2fe9a89a50850a13abe1bb01b3"
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
