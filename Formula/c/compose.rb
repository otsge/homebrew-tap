class Compose < Formula
  desc "Docker compose like plugin, for Apple containers"
  homepage "https://compose.andon.dev/"
  url "https://github.com/andrew-waters/compose.git",
      tag:      "0.9.0",
      revision: "0ed6aa4caef2990b329e542fc319d4e3471086cc"
  license "MIT"
  head "https://github.com/andrew-waters/compose.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "4c27e60d99360edcd39009634c3e646e32bb1b0af3ac3fdb83031e73bb0f6377"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c90585b862f445c1acd7e85859036871265c22d520468ccfae075057677a9de1"
  end

  depends_on xcode: ["26.0", :build]
  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    system "make", "stamp"
    system "swift", "build", "-c", "release", "--product", "compose", *std_swift_args

    plugin_dir = libexec/"container-plugins/compose"

    (plugin_dir/"bin").install buildpath/".build/release/compose"
    plugin_dir.install buildpath/".build/config.toml"
  end

  post_install_steps do
    mkdir_p "{{HOMEBREW_PREFIX}}/libexec/container-plugins"
    symlink "{{libexec}}/container-plugins/compose", "{{HOMEBREW_PREFIX}}/libexec/container-plugins/compose",
            overwrite: true
  end

  test do
    assert_predicate libexec/"container-plugins/compose/bin/compose", :executable?
  end
end
