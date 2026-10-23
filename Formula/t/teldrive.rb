class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.11",
        revision: "bb04ecb1a375a1082f796b07c2b273890dca6910"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "08fbf6c0184897b806e7f2a86418745fa2b150fc4b46d5dcd8e375dfa455deca"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2b82fac2dd6e119ee78f1d331347d3389de3416db70816e67c62528a1b8d9a25"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "cf72c0777e38855e40083d3b076bbf52d5de8320df5a6234542bfeabed6f6ec9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "215c2ae97614ea64f8963d15f0a50861fc65dd5eee9ea299d3bfdcfd3f3ce548"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "80f3fa6ff2c06919f1aa4dc2b2679e439e9209611ec8d7db265ce9eeecd81dbd"
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
