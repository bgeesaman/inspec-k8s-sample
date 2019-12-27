# Example Kubernetes (K8s) Chef InSpec Profile

This example shows the implementation of an InSpec profile using the [inspec-k8s](https://github.com/bgeesaman/inspec-k8s) resource pack.

## Preconditions

- Inspec 3.7+ or 4.x+
- InSpec K8s train/backend plugin [train-kubernetes](https://github.com/bgeesaman/train-kubernetes)

## Usage

1. Clone this repo
1. Ensure your `KUBECONFIG` env var or `~/.kube/config` is set to a valid kube config that is pointing to the target cluster with valid credentials to see resources.
1. Run: `inspec exec . -t k8s://` from inside the root of this repo.
1. Modify `controls/*.rb` as desired.

## Example controls

### Singular Resource -- Namespace

```
control "k8s-1.0" do
  impact 1.0
  title "Validate built-in namespaces"
  desc "The kube-system, kube-public, and default namespaces should exist"

  describe k8sobject(api: 'v1', type: 'namespaces', name: 'kube-system') do # get a single resource
    it { should exist }
  end
  describe k8sobject(api: 'v1', type: 'namespaces', name: 'kube-public') do
    it { should exist }
  end
  describe k8sobject(api: 'v1', type: 'namespaces', name: 'default') do
    it { should exist }
  end
end
```

### Plural Resources -- Pods with labelSelectors and custom output

```
control "k8s-1.1" do
  impact 1.0
  title "Validate kube-proxy"
  desc "The kube-proxy pods should exist and be running"

  k8sobjects(api: 'v1', type: 'pods', namespace: 'kube-system', labelSelector: 'k8s-app=kube-proxy').items.each do |pod| # Loop through each pod found
    describe "#{pod.namespace}/#{pod.name} pod" do  # customize the output message with the pod ns/name
      subject { k8sobject(api: 'v1', type: 'pods', namespace: pod.namespace, name: pod.name) }  # Set the target of the test as the pod
      # Run the tests
      it { should exist }
      it { should_not have_latest_container_tag }
      it { should be_running }
    end
  end
end
```

### Other notes

The `k8sobject` library is very barebones, and an area for improvement are more helper functions to help keep tests clean and readable.  That said, the `k8sobject.item` object is the full struct of the returned resource.
