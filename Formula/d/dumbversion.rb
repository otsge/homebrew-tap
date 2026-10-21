class Dumbversion < Formula
  desc "Smart way to make diffs between massive files"
  homepage "https://github.com/thecatontheceiling/DumbVersion"
  url "https://github.com/thecatontheceiling/DumbVersion/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "d9500c5f7749e923150d6878789057a4890863b0992d4a0d0866f96482510a15"
  license "GPL-3.0-or-later"
  head "https://github.com/thecatontheceiling/DumbVersion.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any, arm64_golden_gate: "b05da4fb1e69a109e250dd7ccbf681b24f7854108acf5824aaaa8eeaaeed7c4c"
    sha256 cellar: :any, arm64_tahoe:       "1a8302a625f53f181930f20bcfd4a7e9e9549e654a3fc6385c54f1fd41db22b4"
    sha256 cellar: :any, arm64_sequoia:     "4f07373e759d932d09965897fc26b7294ad9c71b5331fe4cedb8534a951b501a"
    sha256 cellar: :any, arm64_linux:       "836a953390df9cb1bdd1d732d01232700b59a28e8b624e37a07a5cad4878e512"
    sha256 cellar: :any, x86_64_linux:      "0d9f89cd25423c92397384a9b0237f2fb80948b33840efc3f234f43e987ca0b3"
  end

  depends_on "dotnet" => :build
  depends_on "brotli"
  depends_on "openssl@4"

  def install
    dotnet = Formula["dotnet"]
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"

    if OS.linux?
      ENV["DOTNET_CLI_HOME"] = "/tmp"
      ENV["XDG_DATA_HOME"] = "/tmp"
      ENV["XDG_RUNTIME_DIR"] = "/tmp"
    end

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
