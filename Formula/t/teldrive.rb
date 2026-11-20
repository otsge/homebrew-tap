class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.14",
        revision: "a7c3e59f979e20a1d01bb3be77f5a7e96a9b7dc7"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "d20d1952b4c1c685edb82d730999670a7f19124222d1034600e7391d4a15e0a7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "5a2d642b3ae779efc7de07d6ea2e237e6c1f9aa83479d5d506e933be2f53e984"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "bcf2e1828f8914279c61be6f69109bb9013a4dec8a62b193e400d625b6e66e40"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c539c365d1bb19e4454a66c2edd9378207fe4f1018636090b249d6841b139508"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "db8a8d69b7d192fd3217077a243dd850ca39f081bb2a5fb26e12bbee50eecebc"
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
