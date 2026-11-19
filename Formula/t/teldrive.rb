class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.13",
        revision: "c9c366aae22dae591475f8efabacf0e1bc211801"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d3cc08c57ca8769fc6f4382c8eaed70c41c786ea0df18f6987221ecadcb5a6ac"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e61a65ceebe8efe228427e3ad15f3edf21cc43994409299e016903a602069fba"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f6b0f18a38bd885baed1d6252709662e52099c8ae97509fca7ff544d79c64ae2"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "e7f201f194da83f5076bcf9ee5f0d0a8762240997f52bb8267d430294689480b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "6f14a329bfa06a75efb3e6ca3fa13c2cac1799e2ceef3891576dd9ab7e851c69"
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

    generate_completions_from_executable(bin/"teldrive", shell_parameter_format: :cobra)
  end

  test do
    system bin/"teldrive", "version"
  end
end
