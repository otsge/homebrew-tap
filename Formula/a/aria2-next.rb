class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.6",
      revision: "b810101e3174ccbbe653866ea91f50d1cc262a16"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5924c3fd525ad0397ffddedf26bdf5805e3c6d103bcdc6855ef35f90b086d571"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "160749bf1ed6a238b66ed09ab78579f045118ac4eb30484e37625539c2e8ab62"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "253e9f7720ac6dd0d90c7227c79d205f1afb6893b9ed37f150d86a5d1264fc9b"
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
