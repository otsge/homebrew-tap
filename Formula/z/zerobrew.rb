class Zerobrew < Formula
  desc "Fast package manager alternative to Homebrew, written in Rust"
  homepage "https://github.com/lucasgelfond/zerobrew"
  url "https://github.com/lucasgelfond/zerobrew/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "696fb9028a4b553fe87eb58af81f44f0676312e07ed89be78fc0886f1f3127a5"
  license all_of: ["Apache-2.0", "MIT"]
  head "https://github.com/lucasgelfond/zerobrew.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4c320fbd45d71319440928571effdfd74706e7ccca1b7eac5c2b957746b2c092"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7da7354fb90026c5eddd879fb2df6baf6c497796d5287ae4bc3332bf19621545"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9b263868be69c5ee6a57697d7084476d2322c8f4b4ea40836fca2c2b082ccef1"
    sha256 cellar: :any_skip_relocation, tahoe:         "8ebe823d6305eef4744ee8c6b4fd64d21cdc825fb958a1a07221dad0635fd053"
    sha256 cellar: :any_skip_relocation, sequoia:       "4c41da3dcdafaf08d91420463c755224500e6a2de704bf8fafe48e2a9fb33529"
    sha256 cellar: :any,                 arm64_linux:   "6993528ca9de6716bedbc6c7b7f9aedbfc8961e1034fb1c990bdb5d0c021fb19"
    sha256 cellar: :any,                 x86_64_linux:  "045d2a1e183fa3601f1c39d48aebd143d19906849a8be874fcbc6c58965a144b"
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
