class Aria2Next < Formula
  desc "Redefining the next generation of aria2"
  homepage "https://github.com/AnInsomniacy/aria2-next"
  url "https://github.com/AnInsomniacy/aria2-next.git",
      tag:      "v3.0.7",
      revision: "f12dec6c80bb3efe156146609e885a992cf94e40"
  license "GPL-2.0-or-later"
  head "https://github.com/AnInsomniacy/aria2-next.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "fcafa8ec50c4363f9e74e099d6ced3ae648f2c55ac4fc5f02f7213df24a6330c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "bde5892d23b8cc17557a93eed818b7ab23e0ed5e8ef2eb290b7bd72b0207aba4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "1df0ec74417ba61200d1c9c44a7b4ea4da663b56a2b2a971880616f49c1a0464"
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
