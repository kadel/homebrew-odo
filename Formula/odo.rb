class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/odo"
  url "https://github.com/redhat-developer/odo/archive/v0.0.17.tar.gz"
  sha256 "5ae4c6cfa436d4f5d1e3f498ac376114b9742a3ce33fe9214135859e385dcf0b"


  head do
    url "https://github.com/redhat-developer/odo.git"
  end


  depends_on "go" => :build
  depends_on "openshift-cli"

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/redhat-developer/odo").install buildpath.children
    cd buildpath/"src/github.com/redhat-developer/odo" do
      system "make", "bin"
      bin.install "odo"
    end
  end

  test do
    # all other odo commands are requiring running OpenShift cluster
    assert_match version.to_s, shell_output("#{bin}/odo version")
  end
end
