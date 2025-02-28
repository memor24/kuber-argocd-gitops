# /bin/bash

#argocd install: https://github.com/argoproj/argo-cd/releases

# global variables:
KIND_CONFIG=./argocd-cluster/argocd-kind-config.yaml
ARGOCD_NAMESPACE="argocd"

# check function to check if a command already exists
command_exists(){
    command -v "$1" >/dev/null 2>&1
}
# function to install kind
install_kind(){
    if ! command_exists kind; then
        echo "installing kind..."
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
    else    
        echo "KinD already installed"
        #exit 0 
    fi
}

# function for setting up the cluster
setup_cluster(){
    if ! kind get clusters | grep -q kind; then
        echo "creating kind cluster"
        kind create cluster --name argocd-cluster --config "$KIND_CONFIG"
    else
        echo "KinD cluster is already running"
    fi
}

# extract control plane container ID in KinD
ACD_CP_CONTAINER=$(docker ps -q --filter "name=control-plane") # argocd-control-plane

# install argoCD server inside the KinD cluster
docker exec $ACD_CP_CONTAINER bash -c \ "
kubectl create namespace "$ARGOCD_NAMESPACE" && \
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml && \
kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=argocd-server -n $ARGOCD_NAMESPACE"

echo "configuring argoCD server..."
echo "Setting up port forwarding to access argoCD locally https://localhost:8080"
    kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443 & PORT_FORWARD_PID=$!
## use loadbalancer or ingress in prod, instead of port-forwarding! 
    sleep 5 
echo "getting argoCD server initial password to login"
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "initial_password"=$ARGOCD_PASSWORD ## e.g. for cli/gui initial login

# echo "Cleaning up the port forwarding"
# kill $PORT_FORWARD_PID # or kill %1 , since it's the job #1 in the background

echo "argoCD cluster installation and configuration completed successfully!"
echo "argoCD server version:" 
argocd version --short
echo "argo CD UI: https://localhost:8080"
echo "username: admin"
echo "initial password: $ARGOCD_PASSWORD"





