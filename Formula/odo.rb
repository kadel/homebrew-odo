class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/openshift/odo"

  url "https://github.com/openshift/odo.git",
      :tag      => "v1.0.0-beta1",
      :revision => "c226b008cb945a24227da90f4e8e87c86c7d3b80",
      :shallow  => false

  head "https://github.com/openshift/odo.git",
      :shallow  => false

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/openshift/odo").install buildpath.children
    cd buildpath/"src/github.com/openshift/odo" do
      system "make", "bin"
      bin.install "odo"
    end
  end

  test do
    # all other odo commands require running OpenShift cluster
    shell_output("#{bin}/odo version --client || true")
  end
end



