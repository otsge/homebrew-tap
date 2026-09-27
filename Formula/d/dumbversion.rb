class Dumbversion < Formula
  desc "Smart way to make diffs between massive files"
  homepage "https://github.com/thecatontheceiling/DumbVersion"
  url "https://github.com/thecatontheceiling/DumbVersion/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "d9500c5f7749e923150d6878789057a4890863b0992d4a0d0866f96482510a15"
  license "GPL-3.0-or-later"
  head "https://github.com/thecatontheceiling/DumbVersion.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_golden_gate: "3431708c27440833d03ed7708a8adb6c03cf5e3d0eb0bf04b8e6cc0e993f1811"
    sha256 cellar: :any, arm64_tahoe:       "6ccbf779f57591dbc81fc89f23df1970bd4382af251976a315e5753f8c5f6d1f"
    sha256 cellar: :any, arm64_sequoia:     "cce3532978a660c92954cf2f5971c50420b610c569e374cde9a3207d3d390e00"
    sha256 cellar: :any, arm64_linux:       "d02ed024401738cc8d37f6c486592a6779a2426e28200f89ecc24ddd57fa51fc"
    sha256 cellar: :any, x86_64_linux:      "25fe3505266d9cbebe49658083fe0ef4c94c359353f695fca0a2629b30f22599"
  end

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
