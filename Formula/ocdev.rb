class Ocdev < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/ocdev"
  url "https://github.com/redhat-developer/ocdev/archive/v0.0.3.tar.gz"
  sha256 "b06f7071927b3c66a53d8e68cf4afc4ee8feebd295727f12f5dead7ca1c6efe3"

  head do
    url "https://github.com/redhat-developer/ocdev.git"
  end


  depends_on "go" => :build
  depends_on "openshift-cli"

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
