class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "e35b4f20a04866e67c553e2467f9f57e254b67ada1a2e53c74aa9fbf174f5a3d"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "028508f44b481d054b64849e3e29f387e608ffa99275f273cd7ac8fc9eed2499"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "470143b40a7a3058148af7b20cdc55f6e925ae4eea971847a7048c068f669e79"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c90e8f669d98fa1ac30dd7bdcf9c916b72cf4b1db362b640540ae9055b559e72"
    sha256 cellar: :any_skip_relocation, tahoe:         "58238e697a25f883fbb6fedead52856bcf2089b25a80eb9100d29781197fa43f"
    sha256 cellar: :any_skip_relocation, sequoia:       "929c9ebaabef24a0e68daa0ff96d016a3dd542a0105ae2c137d92213c821927a"
    sha256 cellar: :any,                 arm64_linux:   "95c44f530afda89f3586ddaea5ac0de6ca882bd044ebb802f55af5540d6e7875"
    sha256 cellar: :any,                 x86_64_linux:  "f433bfb5ba02d9929dce1d1f6dd835530743b85ee0ab988024dc8a0d39bcc101"
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
