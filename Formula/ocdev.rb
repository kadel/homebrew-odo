class Ocdev < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/ocdev"
  url "https://github.com/redhat-developer/ocdev/archive/v0.0.1.tar.gz"
  sha256 "fc623492b1542ff9af9260765de4574f3b8479e2ebd2d71c46dd2584bc9e35f7"

  depends_on "go" => :build
  depends_on "openshift-cli" => :run

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/redhat-developer").mkpath
    ln_s buildpath, buildpath/"src/github.com/redhat-developer/ocdev"
    system "make", "bin"
    bin.install "ocdev"
  end

  test do
    # all other ocdev commands are requiring running OpenShift cluster
    assert_match version.to_s, shell_output("#{bin}/ocdev version")
  end
end
