class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/redhat-developer/odo"
  url "https://github.com/redhat-developer/odo/archive/v0.0.20.tar.gz"
  sha256 "4d6f9040a947c0e82aa3a0b764ffd5f339c16ec6a87044d2a148157d39374706"

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



