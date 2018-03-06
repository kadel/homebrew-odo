class Ocdev < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/ocdev"
  url "https://github.com/redhat-developer/ocdev/archive/v0.0.2.tar.gz"
  sha256 "36bb37ff5301fe4df8d88da29e8ac0010ef0423c9f917e579f779fca300d48d3"

  head do
    url "https://github.com/redhat-developer/ocdev.git"
  end


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
