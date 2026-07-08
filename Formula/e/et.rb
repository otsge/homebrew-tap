class Et < Formula
  desc "Remote terminal with IP roaming"
  homepage "https://mistertea.github.io/EternalTerminal/"
  url "https://github.com/MisterTea/EternalTerminal/archive/refs/tags/et-v7.0.0.tar.gz"
  sha256 "3580962861589c0b69efd6b385ff92ad8fdf688c91d1a0edc1a83278205e28e8"
  license "Apache-2.0"
  head "https://github.com/MisterTea/EternalTerminal.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/tap"
    sha256 cellar: :any, arm64_tahoe:   "60edabd678015f5669bf8048ba5c2482af505bb4f41813ac325f517b3e0d5f11"
    sha256 cellar: :any, arm64_sequoia: "ebb4057a9e049a47ccd74d891147f01294e4ba6112b086ac2f11b5ce6dd0f676"
    sha256 cellar: :any, arm64_sonoma:  "06e968a445493896300da6b3c8e5a45f2a26c940b2c2ed6f9665d4ce39c8bc67"
    sha256 cellar: :any, tahoe:         "ac8fe2b441a3505074c5621856dd9d877ac64394f603b985a4dfaaa1b0a3d1e7"
    sha256 cellar: :any, sequoia:       "a7ffdf53eee3b18f5e516d1434e862525e8dfac66bc3803ad5790bf940841dc7"
    sha256 cellar: :any, arm64_linux:   "865ee48e1d9e5397a5ac39d2f7aad0f36f502a2ff142bf3198d0fbaee3b19f62"
    sha256 cellar: :any, x86_64_linux:  "d9d17d3e58d263df567d590cc5b35ad2eabf96a3c4b9cf8a447d8741f39e3a9b"
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
