# /bin/bash

#variables
ARGOCD_NAMESPACE="argocd"
APP_NAMESPACE="app-ns"
HELM_CHART_DIR="./cluster/myapp-helm-chart"

# install argoCD and its cli
echo "installing argoCD server"
    kubectl create namespace $ARGOCD_NAMESPACE
    kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "waiting for argoCD to get ready"
    kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=argocd-server -n $ARGOCD_NAMESPACE

# might as well use helm to istall it:
#   helm install argocd argo/argo-cd ---namespace argocd --create-namespace
# to update values before install:
#   helm show values argo/argo-cd > values.yaml 
#   helm install argocd argo/argo-cd -n argocd -f values.yaml

# configure argoCD
echo "configuring argoCD server..."
echo "Setting up port forwarding to access argoCD locally"
    kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443 & PORT_FORWARD_PID=$!
# use loadbalancer or ingress in prod, instead of port-forwarding! 

# deploying the app in argocd server
kubectl create namespace "$APP_NAMESPACE"
kubectl apply -f ./argocd/application.yaml -n app-ns

#########################################################################
# below from argocd client side, same as above from argocd server side 
# echo "dreating the argoCD server in the app namespace" 
#   # parameters same as application.yaml manifest:
#     argocd app create my-app \
#     --repo git@github.com/memor24/kubernetes-gitops-argocd.git
#     --path ../gitops/argocd \ ## path to /application.yaml
#     --dest-server https://kubernetes.default.svc \
#     --dest-namespace default ## or app-ns
#########################################################################
echo "Cleaning up the port forwarding"
kill $PORT_FORWARD_PID # or kill %1 , since it's the job #1 in the background

echo "argoCD server setup and application deployment completed"

####################################################################################

    # extract control plane container ID in KinD as a local variable
    CP_CONTAINER=$(docker ps -q --filter "name=kind-control-plane")

    # installing argoCD CLI (client)
    docker exec $CP_CONTAINER bash -c "curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod +x argocd-linux-amd64 && \
    mv argocd-linux-amd64 /usr/local/bin/argocd"


    echo "version of argoCD client inside KinD"
    docker exec $CP_CONTAINER bash -c "argocd version --short"

##################

# using the installed tools:

# deploying argoCD on the app namespace 
#   # parameters sasme as application.yaml manifest:
#     argocd app create my-app \
#     --repo git@github.com/memor24/kubernetes-gitops-argocd.git
#     --path ../gitops/argocd \ ## path to /application.yaml
#     --dest-server https://kubernetes.default.svc \
#     --dest-namespace default ## or app-ns

echo "getting argoCD server password"
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "initial_password"=$ARGOCD_PASSWORD ## e.g. for cli/gui initial loggin

# login from the cluster (argocd client)
$ARGOCD_PASSWORD is initial password after argoCD server deployed 
    argocd login --username admin --password "$ARGOCD_PASSWORD" --insecure 
add CA and ingress in the chart for security 

# example of what argocd cli commands
    argocd app get my-app
    argocd app sync my-app  ## if syncPolicy is set to manual





