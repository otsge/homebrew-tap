class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "5e80d400b49593a68e1dc9b43821fe7800b038ef7064bebf4f4fc2bf9e174c60"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "86d36a1ea8f4b6b20a8b51c4807a0da9637fc2dad37ac49ce1a6856f1dcdec85"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "56d5d5b095a602199c9aed6b3919843d886f770598c840701b2d5dc95790af70"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3dc3ccccdbbf1958edceb80b70e1fc2572a3dece96a3b704ff3e386ba8e01446"
    sha256 cellar: :any,                 arm64_linux:       "41b84f7eb513dbf6e28e297fe286ae0f4f133b33103c2338ca880294f3b8f74f"
    sha256 cellar: :any,                 x86_64_linux:      "e9a6f7001d96a12756bef5a25aff5a37c0e0baf34b9e91674df5ec93f55f764a"
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
