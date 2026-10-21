class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.9",
        revision: "d9f2dc0115acf3c851a47b742a5e38b7a9e7c709"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "4f2b551fb038aae77642122cf0b04c1c1fc87a4f881228a43f7f684951d878be"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "74ba74b5b81f6a6f94a9344a915fd45e66983376868cc63eda4cfd49c6e942d2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e240428b2db4b3214d8c430a0580f864cb8908128ffb3272e41f5756e8fda391"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "dba74f9541a8354b76ce649600fe39c42207ac20f47551125db920852a02d5fc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "465b2c4789e9b6e290c9885eeb2bed7b09782aee17b632d4283ff41eebf6e0b1"
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
