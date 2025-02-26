#bin/bash

#variables
KIND_CONFIG=./cluster/kind-config.yaml

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
        kind create cluster --name mykind --config "$KIND_CONFIG"
    else
        echo "kind cluster is already running"
    fi
}

# function to install tools inside the cluster
install_tools4_cluster (){
    echo "installing tools -kubectl, helm, argoCD cli- inside the cluster"

    # extract control plane container ID in KinD as a local variable
    CP_CONTAINER=$(docker ps -q --filter "name=kind-control-plane")
    
    
    # installing kubectl
    docker exec $CP_CONTAINER bash -c "curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl"
    
    # installing Helm
    docker exec $CP_CONTAINER bash -c "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh"
}

# function for setup verfication & info
verify_setup(){
    kind get clusters
    CP_CONTAINER=$(docker ps -q --filter "name=kind-control-plane")
    
    echo "version of kubectl inside KinD" 
    docker exec $CP_CONTAINER bash -c "kubectl version --short"
    
    echo "version of helm inside KinD"
    docker exec $CP_CONTAINER bash -c "helm version --short"
}

# calling the functions
echo "setting up kind cluster and configs"
    install_kind
    setup_cluster
    install_tools4_cluster
    verify_setup
echo "KinD is setup and ready..."