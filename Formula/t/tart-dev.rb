class TartDev < Formula
  desc "Run macOS and Linux VMs on Apple Hardware"
  homepage "https://github.com/openai/tart"
  url "https://github.com/openai/tart/archive/refs/tags/2.34.0.tar.gz"
  sha256 "59a4f6a68c8a9cf11a2bcd7a1580a9d6965dd4786d25d8d6743471301b8cadfe"
  license "FSL-1.1-ALv2"
  head "https://github.com/openai/tart.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0a5bf8f4428c10ad80aba6411091f87bb6465a822931e92c0d7007d09d1ff8a4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "dac0d614edd3aa90c14c9d479570a8f2c5763477401fa31c68c1bc6b404140ab"
    sha256 cellar: :any_skip_relocation, tahoe:         "03b7d9249a6f2d5527dbf21fe4107485e7dc0ac8d7eac1594f3698677cfa9d7b"
    sha256 cellar: :any_skip_relocation, sequoia:       "41c9dc99b5f047339d5b0f6ab41fe68825073e6f016678502108f8259f40ab90"
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
