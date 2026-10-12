class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "2.0.4",
        revision: "f3920c6456b602cdb01061a3b76a36884c929c22"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0fe6c16fb5e7019edec84a1e94a399861e6ca6da98cea9602a36a2a25e6e0514"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "5d82873028cfafb08ec079810759468335e8bf3167c8658ba9aefc383eb8793c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4f152311fe4bdd56834adfb72a73927b1223d1a112f0aaea54b34c123fd32151"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2f25d64f436264469ab004005f31593ad92cffa75ce527922b32e34d3827d706"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "1e1f4730a9e47bf25ed38063861f15a7298b6631c62194dc03c7ca841cfabcfc"
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
