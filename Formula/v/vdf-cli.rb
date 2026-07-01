class VdfCli < Formula
  desc "Command-line interface for Video Duplicate Finder"
  homepage "https://github.com/0x90d/videoduplicatefinder"
  url "https://github.com/0x90d/videoduplicatefinder.git",
      tag:      "4.0.x",
      revision: "3901eeadc52b1d831df6f155ffedb5a09004aee0"
  license "CPL-1.0"
  head "https://github.com/0x90d/videoduplicatefinder.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "cdacaeb4beb820b8124e15377d42b0b26b960cb9342e8ea6df265782ca5363ae"
    sha256 cellar: :any, arm64_sequoia: "f81848e6657fd5e7a9951e7515861fa613e3aba770e95e2af5d4abd1d6cc4324"
    sha256 cellar: :any, arm64_sonoma:  "65aef434495601696313be3c8585619e4d643082a358d3ceea81c24d1db92ef6"
    sha256 cellar: :any, tahoe:         "bb50b4d2f2a0bfe2ad000ac0e153d1809880a10c6bbf3d74d0c691f633724b48"
    sha256 cellar: :any, sequoia:       "a8682075a55c99fc4a5d5bd8310134672ae0215c84072eae7b3b2c678b69a03a"
  end

  depends_on "dotnet" => :build
  depends_on "brotli"
  depends_on "ffmpeg"
  depends_on :macos
  depends_on "openssl@3"

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"

    arch = Hardware::CPU.arm? ? "arm64" : "x64"

    args = %W[
      -c Release
      -r osx-#{arch}
      -o #{libexec}
      -p:PublishAot=true
      -p:DebugType=None
    ]
    system "dotnet", "publish", "VDF.CLI/VDF.CLI.csproj", *args
    bin.install_symlink libexec/"vdf-cli"
  end

  test do
    system bin/"vdf-cli", "--version"
  end
end
