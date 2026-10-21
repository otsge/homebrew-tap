class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "c5c604cca5bc0feeb5eccb1b12a69af843401fe9f92fb8130921f4af2d304ad7"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a94c868a37471efcd43d73334cc878b2cc8ca06a7f877c0e4ef1e12cf1986623"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "22fd857012fee215f223a736d8925eb34f22d4be0a1f7e8fe25f50ff026e83a9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4dd7899da156a2d624d522961eaf23ecbada935cea30fc33da32734e76a6b153"
    sha256 cellar: :any,                 arm64_linux:       "234fad95980952cf9ed010475cc02c7ca0ba2b1145f39d609b9f3beb1379ce05"
    sha256 cellar: :any,                 x86_64_linux:      "60aeeeed6aed7b0f665eb85c12e12e1bdcf47af301fafe34cd4f6a11ac0b9fbd"
  end

  depends_on "rust" => :build

  def install
    ENV["LZMA_API_STATIC"] = "1"

    system "cargo", "install", *std_cargo_args(path: "zb_cli")

    generate_completions_from_executable(bin/"zb", shell_parameter_format: :cobra)
  end

  test do
    system bin/"zb", "--version"
  end
end
