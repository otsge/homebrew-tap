class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.7",
        revision: "d658224384f827e6922d3a414d6638269178ece4"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "71ac3cc1057a00352a108c3fcaabcda2df14cffe2e3e38690957893e91914bb4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "6d4315a96a1912c9b6eee6e2c6d44510b47a1e0d695bbbcf8729daa66b3a3092"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "29a4bbd0815b358bf221b7ca8b0f469571e51ed1e6ab8e7656510c2bb91d518e"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "8334ef8f0cf9f2ab1a650fe95e0e367e4b8b09666465ca4640fb6a0bbbf0564c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "20c472cc0c0b48b57f81176b5ae7bfcf4c44372f59cf937f4319c3218fd07b4a"
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
