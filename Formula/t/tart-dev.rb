class TartDev < Formula
  desc "Run macOS and Linux VMs on Apple Hardware"
  homepage "https://github.com/openai/tart"
  url "https://github.com/openai/tart/archive/refs/tags/2.35.0.tar.gz"
  sha256 "f1b148c3a9dce2fb449e0c7431668c4cd107c7d46f080d32e52c293b1be4a393"
  license "FSL-1.1-ALv2"
  head "https://github.com/openai/tart.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "475da61c52269a04447d789c0c643db6c56fdf75e7d9592af7ad2c38a13b5859"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e1482b3906008ef1c5d4403e19e7e26258bfd32d9328fa22b16debb67a92e9b1"
    sha256 cellar: :any_skip_relocation, tahoe:         "4a67b91859fcfe5df773464e2a3441083d2cabdc2ce243a3b55f8ec445b7a8aa"
    sha256 cellar: :any_skip_relocation, sequoia:       "9d33e4f3bce8b14a62e3557aded757de6da3ed0e060cf2f60c47ce7af1e3fe6f"
  end

  keg_only :versioned_formula

  depends_on xcode: ["16.3", :build]
  depends_on :macos

  uses_from_macos "swift" => :build, since: :sequoia # swift 6.3+

  def install
    arch = Hardware::CPU.intel? ? "x86_64" : "arm64"

    args = %W[
      --arch=#{arch}
      --configuration=release
      --disable-sandbox
    ]

    system "swift", "build", *args
    mkdir_p ["tart.app/Contents/MacOS", "tart.app/Contents/Resources"]
    cp ".build/#{arch}-apple-macosx/release/tart", "tart.app/Contents/MacOS/tart"
    cp Dir["Resources/{embedded.provisionprofile,Info.plist}"], "tart.app/Contents/"
    cp Dir["Resources/actool/{*.icns,*.car}"], "tart.app/Contents/Resources/"
    system "strip", "tart.app/Contents/MacOS/tart"
    libexec.install "tart.app"
    bin.install_symlink libexec/"tart.app/Contents/MacOS/tart"
  end

  def post_install
    system "xattr", "-cr", libexec.to_s
    generate_completions_from_executable(bin/"tart", "--generate-completion-script")
  end

  def caveats
    <<~EOS
      Tart has been installed. You might want to reduce the default DHCP lease time
      from 86,400 to 600 seconds to avoid DHCP shortage when running lots of VMs daily:

        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.InternetSharing.default.plist bootpd -dict DHCPLeaseTimeSecs -int 600

      See https://tart.run/faq/#changing-the-default-dhcp-lease-time for more details.
    EOS
  end

  test do
    assert_predicate libexec/"tart.app/Contents/MacOS/tart", :executable?
  end
end
