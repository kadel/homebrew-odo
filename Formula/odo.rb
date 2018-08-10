class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/odo"
  url "https://github.com/redhat-developer/odo/archive/v0.0.9.tar.gz"
  sha256 "43228304417d19e073de5be35899d5b12d33285437c55fd96dd6cfd52a8389df"

  head do
    url "https://github.com/redhat-developer/odo.git"
  end


  depends_on "go" => :build
  depends_on "openshift-cli"

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/redhat-developer").mkpath
    ln_s buildpath, buildpath/"src/github.com/redhat-developer/odo"
    system "make", "bin"
    bin.install "odo"
  end

  test do
    # all other odo commands are requiring running OpenShift cluster
    assert_match version.to_s, shell_output("#{bin}/odo version")
  end
end
