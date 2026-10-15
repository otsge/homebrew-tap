class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "caf2388bd79b6ece192b117f7c08051c347eba72fd5245d6e01fb2b871af9c61"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b84bfdcdf86b17679b003b113b3b0188f1aa3c27f7a1326c99a5afae2df9f8db"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "01f758f837ceb96b828e385d585d21e6dc18aa487b24dc5e300bfd21392588a2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a7b77d6cd6c9cf2c9aca833e588335f7e7addf2b614ce90f74d62e41b549d570"
    sha256 cellar: :any,                 arm64_linux:       "93a67ef7644f47f4221ec15f60f8e25c53db0e8e5a217ac3d1a549f654612100"
    sha256 cellar: :any,                 x86_64_linux:      "40b0c60902d694e05a32e0cc9e218a3ec882123d7f9cc36560a5d6f1a22bbb2c"
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
