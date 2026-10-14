class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.5",
        revision: "48e07f017f9d36a0b72ebd2af66974ff6d11a8a1"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8ba0fc7c5f68a8d567412da4295cbd4fe280326b7428882f16f569b13e48b1e1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "95cf91a9d5d3750e6cfedcd63f459e4ba755532e585b8d9ce740b7207223d703"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "f6a84b3e1eb41a8944946908cda3cb34556adfe8219ea4c759ff91b1ae725659"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "5ec536c5ce759e0679dcbbab47f4472608d4d80eeab4b22bdb8d1c7f0bafbbc7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "2d66363d8ac164602e1429a73ee55718bfa30ef402bfa391d51ee9367d485f78"
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
