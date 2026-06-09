class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.2/forgejo-src-15.0.2.tar.gz"
  sha256 "c52a7df751de7426657bc06df336248e05fb663bcc9205e870557ce6a020a199"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d3d7b14c0449618c66ee26feacbb59d456f9d52b8b73ee29d26e96743b3107f5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7cedf56208893d75f598d3e2f565af5c94054ea693f3daed674b6b17c4c7e8c5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a4920470c708816f27b96c7f5700a2719ddc5d1887c95742c82016efe20be85a"
    sha256 cellar: :any_skip_relocation, tahoe:         "3ef54b99abb747d72c6c5cdf66c33349ad9c54364486b4370f8feae3c6eec92a"
    sha256 cellar: :any_skip_relocation, sequoia:       "121b6a83dffd3dce4b1fb983290363f2f4d2582047b8be830d19eb952884c2d5"
    sha256 cellar: :any,                 arm64_linux:   "8b2ff72b1d3c06fc86d6de2c96d66fb224bca1b78864669f8123349660397d2f"
    sha256 cellar: :any,                 x86_64_linux:  "e34811e701540132a72250c20b876a585e91de89b5520277cced2b4e46154b57"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea" => "forgejo"
    bin.install "environment-to-ini"
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path var/"log/forgejo.log"
    error_log_path var/"log/forgejo.log"
  end

  test do
    ENV["FORGEJO_WORK_DIR"] = testpath
    port = free_port

    pid = spawn bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s

    output = shell_output("curl --silent --retry 5 --retry-connrefused http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl --silent http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
