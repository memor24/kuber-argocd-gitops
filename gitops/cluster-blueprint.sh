# /bin/bash

################## argoCD namespace #####################


#argocd install: https://github.com/argoproj/argo-cd/releases

# global variables:
KIND_CONFIG=./argocd-cluster/argocd-kind-config.yaml
ARGOCD_NAMESPACE=argocd

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
        kind create cluster --name my-cluster --config "$KIND_CONFIG"
    else
        echo "KinD cluster is already running"
    fi
}

# extract control plane container ID in KinD
CP_CONTAINER=$(docker ps -q --filter "name=control-plane") # argocd-control-plane

# install argoCD server inside the KinD cluster
docker exec $CP_CONTAINER bash -c \ "
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


################## my-app namespace #####################


#bin/bash

# global variables:
KIND_CONFIG=./app-cluster/app-kind-config.yaml
APP_NAMESPACE="my-app-ns"
HELM_CHART_DIR="./app-cluster/helm-chart"
####

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
        kind create cluster --name app-cluster --config "$KIND_CONFIG"
    else
        echo "KinD cluster is already running"
    fi
}

# function to install tools inside the cluster
install_tools4_cluster (){
    echo "installing tools -kubectl, helm- inside the cluster"

    # extract control plane container ID in KinD as a local variable
    CP_CONTAINER=$(docker ps -q --filter "name=control-plane")

    # installing kubectl
    docker exec $CP_CONTAINER bash -c "curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl"
    
    #  installing Helm
    docker exec $CP_CONTAINER bash -c "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh"

}

# function for setup verfication & info
verify_setup(){
    kind get clusters

# extract control plane container ID in KinD as a local variable
    CP_CONTAINER=$(docker ps -q --filter "name=control-plane")
    
    echo "version of kubectl inside KinD" 
    docker exec $CP_CONTAINER bash -c "kubectl version"
    
    echo "version of helm inside KinD"
    docker exec $CP_CONTAINER bash -c "helm version --short"
}

deploy_app(){
# extract control plane container ID in KinD as a local variable
    CP_CONTAINER=$(docker ps -q --filter "name=control-plane")
   
docker exec "$CP_CONTAINER"  bash -c << 'EOF'
if [ -d ./app-cluster/helm-chart ] ; then 
            helm lint "./app-cluster/helm-chart" && 
            helm install my-app "./app-cluster/helm-chart" --namespace my-app-ns && 
            echo "the app status is:" && 
            helm status my-app 
            echo "finished deploying my-app"
    else
            echo "helm chart directory doesn't exist."
fi
EOF
}

# calling the functions
echo "setting up my-app cluster and configs"
    install_kind
    setup_cluster
    install_tools4_cluster
    verify_setup
echo "KinD cluster is setup and ready..."
echo "deploying the application in the cluster"
    deploy_app

