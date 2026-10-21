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
    rebuild 1
    sha256 cellar: :any, arm64_golden_gate: "6837c116ba1261ed7ba693edad9fd207b7dc23620ad13af26907a3e669ad5822"
    sha256 cellar: :any, arm64_tahoe:       "4780e9b5c6703115fc570350c21f0dfdedeeb0ff238c0c3cb43d7f39288e5b5e"
    sha256 cellar: :any, arm64_sequoia:     "d31ced65c98fd0e408300e310394ad51fb2323be21f30473a196f56cb6548d82"
  end

  depends_on "dotnet" => :build
  depends_on "brotli"
  depends_on "ffmpeg"
  depends_on :macos
  depends_on "openssl@4"

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
