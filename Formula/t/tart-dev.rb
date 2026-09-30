class TartDev < Formula
  desc "Run macOS and Linux VMs on Apple Hardware"
  homepage "https://github.com/openai/tart"
  url "https://github.com/openai/tart/archive/refs/tags/2.40.1.tar.gz"
  sha256 "f2753cc955ba1c8afd08cf91c155bd1cd78e8ef1470f2f82e7d20e15d3f0f20b"
  license "FSL-1.1-ALv2"
  head "https://github.com/openai/tart.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "62c28c80099a941b0162d412ce64b69bea51a04e958833095c9929b156ba71b4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d3971307aa9b2b699225474ae2061d1e84be3b1552aa08bad9c6c2ceada79f51"
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
