class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.11",
        revision: "bb04ecb1a375a1082f796b07c2b273890dca6910"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "87f433d495246b12b0feb7fa91bf56abb50a50a84b392a138f11319b5a47b2c1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d3b9a0968e58f09e13eeea84b0e9a750930f4ec00b92778fc254ff066d565f43"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a668c7e273fee3cdca84c94076dd9b59cc89a07acd768c3f3af871bfdbc3368c"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "590be8e497f65b4444ec2dc2c3e104f6e1f222a0e79bc7b4ce738541e59a927a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "ccf80f53c0eada11d118fd36302490a0eec5e5b9d05d0c8f0746c7a0b9834f5d"
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
