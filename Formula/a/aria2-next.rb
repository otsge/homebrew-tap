class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.0",
      revision: "40d9fe5807368a8ebb0c063ff81d5b5214d6ad7f"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c51f9794c63dd70b6a4e623dcbeb0062f275b0ecf63e8443f9943d6be27ca465"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "6e9323e6d212c7b67b2a32bf626570593bbad3ae8ac8a68338b73401141f51af"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0be07333face097a88efe681042ea8855f17dd5a631e042aa761eef02236981f"
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
