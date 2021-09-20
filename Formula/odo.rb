class Odo < Formula
  desc "Developer-focused CLI for Kubernetes and OpenShift"
  homepage "https://github.com/openshift/odo"

  url "https://github.com/openshift/odo.git",
  :tag      => "v2.3.1",
  :revision => "2ae31fb6697241000f4084c004ac97100e0ce5e2"

  head "https://github.com/openshift/odo.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath / "src/github.com/openshift/odo").install buildpath.children
    cd buildpath / "src/github.com/openshift/odo" do
      system "make", "bin"
      bin.install "odo"
    end
  end

  test do
    # test version
    version_output = shell_output("#{bin}/odo version 2>&1").strip
    tag = stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:tag]
    short_rev = stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision].slice(0, 7)
    assert_match "odo #{tag} (#{short_rev})", version_output

    # try set preference
    ENV["GLOBALODOCONFIG"] = "#{testpath}/preference.yaml"
    shell_output("#{bin}/odo preference set UpdateNotification true")
    assert_predicate testpath/"preference.yaml", :exist?

    # almost all other odo commands require connection to OpenShift cluster 
  end
end

