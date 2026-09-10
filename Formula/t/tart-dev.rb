class TartDev < Formula
  desc "Run macOS and Linux VMs on Apple Hardware"
  homepage "https://github.com/openai/tart"
  url "https://github.com/openai/tart/archive/refs/tags/2.37.0.tar.gz"
  sha256 "39df119ae301cd61864fbf1b170123eb3845819a24828a64c1eefc91199b1277"
  license "FSL-1.1-ALv2"
  head "https://github.com/openai/tart.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "11585d82efcdc0904996957bb2975a6e3a923c213e1331eefe0e4547cec3b0f6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "960f5a8dbe980818e0ac2c55389274757116d4d5652dab86cc74c96ac84befc7"
    sha256 cellar: :any_skip_relocation, tahoe:         "ad23cdb09973a1a2e60d0a5c23ff448b4573738bd4119abed937459c796d5bfa"
    sha256 cellar: :any_skip_relocation, sequoia:       "eecf79b8f98758dc120cb4d558df69d9b13d38f31f8e4b6d746c22be38c8a1fb"
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
    run "xattr", args: ["-cr"], base: :libexec
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
