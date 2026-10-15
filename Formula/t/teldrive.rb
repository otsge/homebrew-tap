class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.6",
        revision: "081ba5e194b0d3f35d5e5a7cfd632718774437a7"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "05fdf1668ca01aec72981dc69ec315ff61fe7b918e793b125cf2474909b763a9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "31edcbd5bdf10ddd0d8c4c6b40b4fcb8cf1692058e68f4b6ff31afc02eb0ee29"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "25daab7a9590f555b5f558a43dc16c3b1d40abdc8d098397cbb38d4f33d4a5ec"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "702cddbd1cd85bc3091ad8effee6f9cfd4a4d465bc1bf59777a5b8a236b885e3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "43dba7c6d450beece97f74652c66a9de34f6be0504b25288e7e60d920953aaf5"
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
