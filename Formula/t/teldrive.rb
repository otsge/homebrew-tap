class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.2",
        revision: "9dc8bf16d2692a41d4c1b755224d30f7426414f4"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "45229f4f7a36ca11e3d59f8ddf430f4a3254deedbb0b5dcda4a1b225763c4f67"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3897135f4f4484a300747fb885755f361e81a615a34cb74194ab7bc3cca2c7af"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2750c0d115adbc570120d5666e92e7ff32f2522f4f130ae95945724a713cefb4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "927220ea0d92eea30bf5b32da2a8693b81903f69efe79a973f4dc8d53034daa0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "f91839b4ced3c11f0433b7c54c3e572631282b8eff96969e9e8f9bc3351bcf3f"
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
