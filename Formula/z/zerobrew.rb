class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "6a4707445597e56eaf4010e2bfec3266c2e465e39fc13f44cb3ffdf451f844e6"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7ab42c42fab6fd9e017df1047fdd006d1d4f34e76463aca4872ee7fe35f2a012"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "629d86de50e7e5bea7d5bd9f0ef2365b11fda3b8d18ec8cdb9b702a079d409a4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "8ab6063b6fb6c801c9b6e7b175c88a8bfa8debe9ff37da0a7f9ca666af28c47c"
    sha256 cellar: :any,                 arm64_linux:       "31981ba6f1f634c7b45abb96c44d9a389eeafea4c181242643bff0fbb4e6d92b"
    sha256 cellar: :any,                 x86_64_linux:      "574858841f1fbd8f7a7fa26ccc1dfd948c83587ac794f3830bdd9e19fcf48b75"
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
