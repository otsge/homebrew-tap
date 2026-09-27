class Dumbversion < Formula
  desc "Smart way to make diffs between massive files"
  homepage "https://github.com/thecatontheceiling/DumbVersion"
  url "https://github.com/thecatontheceiling/DumbVersion/archive/refs/tags/v1.2.1.tar.gz"
  sha256 "f7830f9a8b8e110febec8e60b950df115d0c0a4a0805e703e304bc525112f0ff"
  license "GPL-3.0-or-later"
  head "https://github.com/thecatontheceiling/DumbVersion.git", branch: "master"

  depends_on "dotnet" => :build
  depends_on "brotli"
  depends_on "openssl@3"

  def install
    dotnet = Formula["dotnet"]
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"

    os = OS.mac? ? "osx" : "linux"
    arch = Hardware::CPU.intel? ? "x64" : "arm64"
    runtime = "#{os}-#{arch}"

    args = %W[
      -c Release
      -r #{runtime}
      -o #{libexec}
      -p:DebugType=none
      -f net#{dotnet.version.major_minor}
      --use-current-runtime
    ]
    system "dotnet", "publish", "DumbVersionCreator/DumbVersionCreator.csproj", *args
    system "dotnet", "publish", "DumbVersionPatcher/DumbVersionPatcher.csproj", *args
    bin.install_symlink [libexec/"DumbVersionCreator", libexec/"DumbVersionPatcher"]
  end

  test do
    system bin/"DumbVersionCreator", "--help"
    system bin/"DumbVersionPatcher", "--help"
  end
end
