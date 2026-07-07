class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTerminal/"
  url "https://github.com/MisterTea/EternalTerminal/archive/refs/tags/et-v7.0.0.tar.gz"
  sha256 "3580962861589c0b69efd6b385ff92ad8fdf688c91d1a0edc1a83278205e28e8"
  license "Apache-2.0"
  head "https://github.com/MisterTea/EternalTerminal.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "21f0379be4fe40ff65bf949ac66d8adc79fc88b68f9354f764f4774d8ad2811b"
    sha256 cellar: :any, arm64_sequoia: "e9c99911fe8f376eea4968bf7dc68f4238192f0443376ab1ce0adf137b541be6"
    sha256 cellar: :any, arm64_sonoma:  "6fa4ef6418865936e453a5ac347ed5f15354636605de7791de7db6927a038d9d"
    sha256 cellar: :any, tahoe:         "af7e7bde45a15ce5a3f7ca261e43eaad3130de732215e3b85830588efcff2347"
    sha256 cellar: :any, sequoia:       "6d22637170f48558ae180fe9db0da538b968bd6592805ebb9220e9944b585ad6"
    sha256 cellar: :any, arm64_linux:   "627d50990fac9bfe0cbb3470d2e790e70abfa1361974b3753cbcb08267edfcef"
    sha256 cellar: :any, x86_64_linux:  "fdb55723a2e23e03bb34b1ca68f995bd268d4dc7167c4bcc6e208647dabb7326"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "libsodium"
  depends_on "openssl@4"
  depends_on "protobuf"

  on_linux do
    depends_on "brotli"
    depends_on "zlib-ng-compat"
  end

  def install
    # https://github.com/protocolbuffers/protobuf/issues/9947
    ENV.append_to_cflags "-DNDEBUG"
    # Avoid over-linkage to `abseil`.
    ENV.append "LDFLAGS", "-Wl,-dead_strip_dylibs" if OS.mac?

    args = %W[
      -DDISABLE_VCPKG=ON
      -DDISABLE_SENTRY=ON
      -DDISABLE_TELEMETRY=ON
      -DBUILD_TESTING=OFF
      -DBASH_COMPLETION_COMPLETIONSDIR=#{bash_completion}
      -DOPENSSL_ROOT_DIR=#{formula_opt_prefix("openssl@4")}
      -DPYTHON_EXECUTABLE=#{which("python3")}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    etc.install "etc/et.cfg"
  end

  service do
    run [opt_bin/"etserver", "--cfgfile", etc/"et.cfg"]
    keep_alive false
    working_dir HOMEBREW_PREFIX
    error_log_path "/tmp/etserver.err"
    log_path "/tmp/etserver.log"
    require_root true
  end

  test do
    port = free_port
    pid = fork do
      exec bin/"etserver", "--port", port.to_s, "--logtostdout"
    end

    begin
      require "socket"
      Timeout.timeout(60) do
        loop do
          TCPSocket.open("127.0.0.1", port).close
          break
        rescue Errno::ECONNREFUSED
          sleep 1
        end
      end
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
