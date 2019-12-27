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

## Docker Usage

1. Clone this repo
1. Run `make build` to build the Docker Image and accept the Chef Inspec License
1. Ensure your valid kube config is in `~/.kube/config` in the proper context targeting the desired cluster.
1. Run `make run`

```
Running in bgeesaman/inspec-k8s-runner:latest: inspec exec . -t k8s://

Profile: InSpec K8s Profile (inspec-k8s-sample)
Version: 0.1.0
Target:  kubernetes://kubernetes.docker.internal:6443

  ✔  k8s-1.0: Validate built-in namespaces
     ✔  kube-system is expected to exist
     ✔  kube-public is expected to exist
     ✔  default is expected to exist
  ✔  k8s-1.1: Validate kube-proxy
     ✔  kube-system/kube-proxy-gr8cw pod is expected to exist
     ✔  kube-system/kube-proxy-gr8cw pod is expected not to have latest container tag
     ✔  kube-system/kube-proxy-gr8cw pod is expected to be running
  ✔  k8s-1.2: Validate kube-dns
     ✔  kube-system/coredns-5c98db65d4-cxl42 pod is expected to exist
     ✔  kube-system/coredns-5c98db65d4-cxl42 pod is expected not to have latest container tag
     ✔  kube-system/coredns-5c98db65d4-cxl42 pod is expected to be running
     ✔  kube-system/coredns-5c98db65d4-vt4rb pod is expected to exist
     ✔  kube-system/coredns-5c98db65d4-vt4rb pod is expected not to have latest container tag
     ✔  kube-system/coredns-5c98db65d4-vt4rb pod is expected to be running


Profile: InSpec Profile (inspec-k8s)
Version: 0.1.2
Target:  kubernetes://kubernetes.docker.internal:6443

     No tests executed.

Profile Summary: 3 successful controls, 0 control failures, 0 controls skipped
Test Summary: 12 successful, 0 failures, 0 skipped
```

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
