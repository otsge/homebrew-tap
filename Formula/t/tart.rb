class Tart < Formula
  desc "Run macOS and Linux VMs on Apple Hardware"
  homepage "https://github.com/openai/tart"
  url "https://github.com/openai/tart/archive/refs/tags/2.33.0.tar.gz"
  sha256 "65f339eb17db8f21a9404346f3bcfab396dad22f07de52772096dbe1c991c4ec"
  license "FSL-1.1-ALv2"
  head "https://github.com/openai/tart.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0d1f032dc91540be27a8f49bc14198c2345a767874a0b887adadfec9f2530029"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e31b0027311eb11a6e7d0cf75b7e282c6d619660519758f2770162475772301e"
    sha256 cellar: :any_skip_relocation, tahoe:         "47c9ce74de1b8d83e557fa31a4b9244e129f86eb80d6a83e873fec9bae68b24e"
    sha256 cellar: :any_skip_relocation, sequoia:       "12f79c7d345eaddee3c810532fdc9407e55116bdbbb5117b0ef004c809c7e2cc"
  end

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
