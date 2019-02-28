class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/odo"
  url "https://github.com/redhat-developer/odo/archive/v0.0.20.tar.gz"
  sha256 "cb5d2894905a470e7e41431334d6a2915b214b5089e83d82015686bfa6a99133"

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



