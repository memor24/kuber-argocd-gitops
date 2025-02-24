#bin/bash

echo "installing KinD"
    echo "installing kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

# setting up the cluster
echo "creating a kind cluster"
kindsetup (){
  if ! kind get cluster | grep -q kind; then
    echo "creating kind cluster..."
    kind create cluster --name mykind 
  else
    echo "mykind cluster is already running!"
  fi
}
# call the function and verify result
kindsetup
echo "kind cluster is:"
kind get cluster


echo "installing kubectl"


echo "installing Helm"

echo "installing argoCD CLI "

