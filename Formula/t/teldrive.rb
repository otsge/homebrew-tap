class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.10",
        revision: "0e63b3929307d4db82febaab6f7b7e8d283e5bd1"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c733fa1c3b294be7bf069001ac4eeb2940b088d5b50de53fbeedd8656c29906f"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4c06614aed3bbaef0c209d96d4a6ac9f7558ace314e8b218f0370394570995c8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f7b2c38f50123c0aad35bb302cc301b0bec9608bb7eafd5b6297659498668638"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c245ab0d38cb29b56e6a5137781ddfe5c807e3933059b35c4e1e5c98d7291875"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "e1519798e18a5131d305a6569ff5d168d660d7badd7b548d0630f8034ee47d3d"
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
