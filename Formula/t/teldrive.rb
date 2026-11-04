class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.12",
        revision: "876f5a22cf03bacf4e694302182137de69d46c9f"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "891f8f314290064b76e5bff1342b85c91336ce3aa7677e2d479e5b59d08cb24e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "32b79313c94ace245d5bf85ec1d813e816729873a9b830e5c48874e72dbb4f44"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2a8d1443f9a30c4b89f715f1b9d04819eb5e1440be1bac2722b02477a601d1aa"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "ae45157bc3c0f6142e2717ae4b4ee1a92fd0f20aa06430126b102c8d55cf80e4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "42768f22fe3f7092d9e543134ee0234ac9ec795f55d657f84a893760dd2f5523"
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
