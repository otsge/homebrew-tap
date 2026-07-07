class VdfCli < Formula
  desc "Command-line interface for Video Duplicate Finder"
  homepage "https://github.com/0x90d/videoduplicatefinder"
  url "https://github.com/0x90d/videoduplicatefinder.git",
      tag:      "4.1.x",
      revision: "726c83c0da061dcd2e66405f28b995026343ab2c"
  license "CPL-1.0"
  head "https://github.com/0x90d/videoduplicatefinder.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "e370b3fa54fd0d345a5626d1b5922cba4de94a642d76e5b3a424b6fd4447f204"
    sha256 cellar: :any, arm64_sequoia: "f02494a7ace3d0ee2618cde9f3dcf68f53550ee904d6c2206fef85593575e704"
    sha256 cellar: :any, arm64_sonoma:  "a9bb90e634bef54bd8e315d8adec9f793d812146763524cc6399c39d316d2e13"
    sha256 cellar: :any, tahoe:         "65a79e1c7ed055ad068257e358cd8a875dc89b5b91f67915930a924ef8a81a35"
    sha256 cellar: :any, sequoia:       "2d38646365c6ea4eec4653f1c1cba9109f4f779a5e212ef419455fafc3c0c6fa"
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
