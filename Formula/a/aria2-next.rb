class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.2",
      revision: "d518e90574e3b933e15aa70241bdc1f766a2dd14"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "6dc23d46e84ef043fd04072499f0c579a48b1873b52e9053f94e3a933376b5fd"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f0617d3c7bdda55e5c6a9ea06f7449aff06aca6fdcf68ad7c6ad523f9b38b98c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "004a76989953fe1bb08d037675393cc92f720a14a5424ba9a6d39eb243b7eeed"
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
