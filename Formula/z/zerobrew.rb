class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "6a4707445597e56eaf4010e2bfec3266c2e465e39fc13f44cb3ffdf451f844e6"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "bb70b59e655bd481dbfeac64a08e83b2419024a1466eef310b281dd2d990cdb1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "dc6145934d494ad864633f32be32da8e6422b3b227b119f57697c67cf143f368"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "93ceb643b49a4ec241900f361e200ccc9e4b38847f6c5da3dde73acbd588fb05"
    sha256 cellar: :any,                 arm64_linux:       "6aee5cfdb0e2e98db7df4ebef898363630d2479c5a1b44abd474e71b4577cd01"
    sha256 cellar: :any,                 x86_64_linux:      "903d1447985b67a50f10cdb59e17c64bb780f10857722adadf7f30cac4e4fa71"
  end

  depends_on "rust" => :build

  def install
    ENV["LZMA_API_STATIC"] = "1"

    system "cargo", "install", *std_cargo_args(path: "zb_cli")

    generate_completions_from_executable(bin/"zb", "completion",
                                         shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    system bin/"zb", "--version"
  end
end
