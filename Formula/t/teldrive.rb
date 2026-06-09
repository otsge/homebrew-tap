class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.8.3",
        revision: "d400a2df41db17ba220cd06973fc8df5c6f2854c"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "20548a0c47154fd4d83b9688259ec7ffad5710a5786f7bab4882d22063529179"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c6adb82acf9e34f23fbe92ca419e259dbfce82e47a230932863cf3bea0160ad2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "0d874d0579c8e84e48ded2a686811831b9b71509eb04e46388b9f78e59fd4c05"
    sha256 cellar: :any_skip_relocation, tahoe:         "72eea298c5b587d5af99655d79c6bc99418df8dd27807dc340837fb21894d833"
    sha256 cellar: :any_skip_relocation, sequoia:       "9e20c41d86f3fb751ff45ee9b2996d507767156022028c654434ec4e9c8b29aa"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "96d9b101ad006cd56b2505a80f01908c7cb38ff8218170d0f0eca212ead4303c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2ead4d77b650eac099cc7ed21c9b6d216affcc7be91024d597c067b54313ba5f"
  end

  depends_on "go" => :build
  depends_on "go-task" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ENV["GO111MODULE"] = "on"
    ldflags = %W[
      -extldflags=-static
      -s -w
      -X github.com/tgdrive/teldrive/internal/version.Version=#{version}
      -X github.com/tgdrive/teldrive/internal/version.CommitSHA=#{Utils.git_short_head(length: 7)}
    ]
    system "task", "ui"
    system "task", "gen"
    system "go", "build", "-trimpath", *std_go_args(ldflags:)
  end

  test do
    system bin/"teldrive", "version"
  end
end
