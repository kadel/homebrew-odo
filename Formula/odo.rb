class Odo < Formula
  desc "OpenShift Command-line for Developers"
  homepage "https://github.com/openshift/odo"

  url "https://github.com/openshift/odo.git",
      :tag      => "v1.0.0-beta5",
      :revision => "4d1d50710db5e9be9e4cbdb0197fc26cc12e6a1a",
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



