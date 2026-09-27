class VdfCli < Formula
  desc "Command-line interface for Video Duplicate Finder"
  homepage "https://github.com/0x90d/videoduplicatefinder"
  url "https://github.com/0x90d/videoduplicatefinder.git",
      tag:      "v4.1.1",
      revision: "21ec967e2e108bb9a2f09f937be000fb1e2c3615"
  license "CPL-1.0"
  head "https://github.com/0x90d/videoduplicatefinder.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_golden_gate: "0ff95364af74ce161382c74192214f163bd3a87ce4338d0b07e4623de87d7081"
    sha256 cellar: :any, arm64_tahoe:       "c8b292ef08f53ff597c3c26d229eb129adc85334d18020532c595bae39a1397f"
    sha256 cellar: :any, arm64_sequoia:     "faff7cd24d06a496ccd8261dcd7259cb88548824bfe00326546f62ae1f1375ae"
  end

  depends_on "dotnet" => :build
  depends_on "brotli"
  depends_on "ffmpeg"
  depends_on :macos
  depends_on "openssl@3"

  def install
    dotnet = Formula["dotnet"]
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"

    inreplace "VDF.Core/Utils/Coreutils.cs", "if (!I", "// if (!I"
    inreplace "VDF.Core/Utils/CoreUtils.cs", /return CurrentFolder/, "// return CurrentFolder"
    inreplace "VDF.Core/Utils/CoreUtils.cs", /"Library", "Application Support"/, "\".local\", \"state\""
    inreplace "VDF.Core/Utils/Logger.cs", /CoreUtils.CurrentFolder/, "\"/tmp\""
    inreplace "VDF.Core/Utils/Logger.cs", "log.txt", "vdf-log.txt"

    args = %W[
      -c Release
      -r osx-arm64
      -o outputCLI
      -p:PublishAot=true
      -p:DebugType=None
      -p:VersionPrefix=#{version}
      -f net#{dotnet.version.major_minor}
      --use-current-runtime
    ]
    system "dotnet", "publish", "VDF.CLI/VDF.CLI.csproj", *args
    system "codesign", "-fs", "-", "--entitlements", "VDF.GUI/Assets/macOS/entitlements.plist", "outputCLI/vdf-cli"
    bin.install buildpath/"outputCLI/vdf-cli"
  end

  test do
    system bin/"vdf-cli", "--version"
  end
end
