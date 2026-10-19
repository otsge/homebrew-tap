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
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "233fa04c75b27283eeff90b1af45b1cc48115b7cad8a67e7fbad507b905f30ae"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "48a8519e54b93e85f4748a31ede2d31e5117e79373c2d7d1d247d582ce5ff391"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "d9cf0eadf85982e6ac1faae394f2ab00d53830b1b08d8187bce664f7e8475388"
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
