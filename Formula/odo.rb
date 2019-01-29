class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/odo"
  url "https://github.com/redhat-developer/odo/archive/v0.0.18.tar.gz"
  sha256 "928326e1ba60cee2b261212e8e6f7a58ff2ca097e195c2462af6b2986a5ceabb"

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
    assert_match version.to_s, shell_output("#{bin}/odo version --client")
  end
end



