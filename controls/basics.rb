title "Kubernetes Basics"

control "k8s-1.0" do
  impact 1.0
  title "Validate built-in namespaces"
  desc "The kube-system, kube-public, and default namespaces should exist"

  describe k8sobject(api: 'v1', type: 'namespaces', name: 'kube-system') do
    it { should exist }
  end
  describe k8sobject(api: 'v1', type: 'namespaces', name: 'kube-public') do
    it { should exist }
  end
  describe k8sobject(api: 'v1', type: 'namespaces', name: 'default') do
    it { should exist }
  end
end

control "k8s-1.1" do
  impact 1.0
  title "Validate kube-proxy"
  desc "The kube-proxy pods should exist and be running"

  k8sobjects(api: 'v1', type: 'pods', namespace: 'kube-system', labelSelector: 'k8s-app=kube-proxy').items.each do |pod|
    describe "#{pod.namespace}/#{pod.name} pod" do
      subject { k8sobject(api: 'v1', type: 'pods', namespace: pod.namespace, name: pod.name) }
      it { should exist }
      it { should_not have_latest_container_tag }
      it { should be_running }
    end
  end
end

control "k8s-1.2" do
  impact 1.0
  title "Validate kube-dns"
  desc "The kube-dns pods should exist and be running"

  k8sobjects(api: 'v1', type: 'pods', namespace: 'kube-system', labelSelector: 'k8s-app=kube-dns').items.each do |pod|
    describe "#{pod.namespace}/#{pod.name} pod" do
      subject { k8sobject(api: 'v1', type: 'pods', namespace: pod.namespace, name: pod.name) }
      it { should exist }
      it { should_not have_latest_container_tag }
      it { should be_running }
    end
  end
end
