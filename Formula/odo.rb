class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/odo"
  url "https://github.com/redhat-developer/odo/archive/v0.0.19.tar.gz"
  sha256 "a4512716c738b8113c6588460cb62348705203329062d1475fbd3661469e45e9"

  head do
    url "https://github.com/redhat-developer/odo.git"
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/redhat-developer/odo").install buildpath.children
    cd buildpath/"src/github.com/redhat-developer/odo" do
      system "make", "bin"
      bin.install "odo"
    end
  end

  test do
    # all other odo commands require running OpenShift cluster
    shell_output("#{bin}/odo version --client || true")
  end
end



