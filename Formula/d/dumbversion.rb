class Dumbversion < Formula
  desc "Smart way to make diffs between massive files"
  homepage "https://github.com/thecatontheceiling/DumbVersion"
  url "https://github.com/thecatontheceiling/DumbVersion/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "d9500c5f7749e923150d6878789057a4890863b0992d4a0d0866f96482510a15"
  license "GPL-3.0-or-later"
  head "https://github.com/thecatontheceiling/DumbVersion.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_golden_gate: "4324b4ff82dc1e2bc7eea2093348c6aabb756d3a6e7932bc3bfcb26bdc3d9e53"
    sha256 cellar: :any, arm64_tahoe:       "00f800c2e167353f12456a81252e935861d6c7cac693ad72b7c5b8ae690cc6cd"
    sha256 cellar: :any, arm64_sequoia:     "be6bdd8f46f0e09779f1fe69d223e7b06fd30da00022708dfe797154078c2278"
    sha256 cellar: :any, arm64_linux:       "323af1a330727805d57cb35d059c12f5c9155aeca80fe53814a44fe89c52a754"
    sha256 cellar: :any, x86_64_linux:      "a4462a6ca188439187384f99f4399d68849c6d931a145612cc499824f052a2ae"
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
