class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.7",
        revision: "d658224384f827e6922d3a414d6638269178ece4"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e256e5a7a8bfe61142f46643c22879dcdd11e09788aac5758598efed420deb87"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "d6bf53334b75a7c5f349d9bb0ea660ad42bb74d830a12c31dbb43a69f7a1d47c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "d6fafef4fdfb586ac5c2b13d9f7a479fdbb0069367b8fc0a58e5e100562ce80a"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "effd58305b6f76672938127c6e929bd760471ae6d31bf465cea576ae00b8b270"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "a419829ed2600ba76679e31f935cdbe6c71b25bedaf1772537050e0fe2d873f7"
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
