class TartDev < Formula
  desc "Run macOS and Linux VMs on Apple Hardware"
  homepage "https://github.com/openai/tart"
  url "https://github.com/openai/tart/archive/refs/tags/2.32.1.tar.gz"
  sha256 "7583628a566f8e24cd17f6bd14c4973f574de574da3e4b84d303da0a25092da4"
  license "FSL-1.1-ALv2"
  head "https://github.com/openai/tart.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "ac956948fd7a47c0457a9cb4ca18301350df3a8705c441bf6178b89688df8309"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "208f7922c8ea1da3881ee4e675820f884fa5b4f6fbd991fb0c1862df0c7f5cc5"
    sha256 cellar: :any_skip_relocation, tahoe:         "4524d56f27fdbea7a3be04a1af1682207af9fd7bb77deedff9f4218242956f51"
    sha256 cellar: :any_skip_relocation, sequoia:       "1e31f4c44648c487aa77fc19f6cf142e9f95b514623dbc1126206bae56ca4987"
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
    bin.write_exec_script "#{libexec}/tart.app/Contents/MacOS/tart"
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
