class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.2",
        revision: "9dc8bf16d2692a41d4c1b755224d30f7426414f4"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8b71980d99de4bcdedb96b757d3b24046c31037fe6136714112fd6d171cd6d51"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "effd86788e9566ca5cf2ed7568ba52945d668610d7bea78047abcd30348a6763"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f62eaf2d33a9170e0e2e8d39c09baa06403d1317c6cf18d5d9ea72a77fd0875e"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "0cb82dc4b060f8465799c1be9787cf01b45a164df197a256543bacc1100a1b43"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "cf87e7ca2f80afdefe7d2e95faeb03feda19bfba3a68fc998d046a2ab5638824"
  end

  depends_on "bun" => :build
  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X main.version=#{version}
      -X main.commit=#{Utils.git_head}
      -X main.date=#{time.iso8601}
    ]
    system "bun", "ci", "--cwd", "ui"
    system "bun", "run", "--cwd", "ui", "build"
    system "go", "build", "-trimpath", *std_go_args(ldflags:), "./cmd/teldrive"
  end

  test do
    system bin/"teldrive", "version"
  end
end
