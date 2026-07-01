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
