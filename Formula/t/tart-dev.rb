class TartDev < Formula
  desc "Run macOS and Linux VMs on Apple Hardware"
  homepage "https://github.com/openai/tart"
  url "https://github.com/openai/tart/archive/refs/tags/2.37.0.tar.gz"
  sha256 "39df119ae301cd61864fbf1b170123eb3845819a24828a64c1eefc91199b1277"
  license "FSL-1.1-ALv2"
  head "https://github.com/openai/tart.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b1056a70daf5628769541873a946d14ca723f438704f469e6cf7767c4ae88161"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d074ac5b3ffd55a596df2c6267d0630977cbad3c47d27ce22de9a5d46eff31ce"
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
    generate_completions_from_executable(bin/"tart", "--generate-completion-script")
  end

  post_install_steps do
    run "/usr/bin/xattr", args: ["-cr", "{{libexec}}"]
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
