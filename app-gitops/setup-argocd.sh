# /bin/bash

#argocd install: https://github.com/argoproj/argo-cd/releases

#variables
ARGOCD_NAMESPACE="argocd"

    # extract control plane container ID in KinD
CP_CONTAINER=$(docker ps -q --filter "name=kind-control-plane")

# install argoCD and its cli
echo "installing argoCD server"
    kubectl create namespace "$ARGOCD_NAMESPACE"
    kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "waiting for argoCD to get ready"
    kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=argocd-server -n $ARGOCD_NAMESPACE

# might as well use helm to istall it:
#   helm install argocd argo/argo-cd ---namespace argocd --create-namespace
# to update values before install:
#   helm show values argo/argo-cd > values.yaml 
#   helm install argocd argo/argo-cd -n argocd -f values.yaml

# configure argoCD server
echo "configuring argoCD server..."
echo "Setting up port forwarding to access argoCD locally https://localhost:8080"
    kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443 & PORT_FORWARD_PID=$!
# use loadbalancer or ingress in prod, instead of port-forwarding! 

# will deploy the app using helm, but can also use `argocd` frm client or `kubectl` from server:
    # kubectl create namespace "$APP_NAMESPACE"
    # kubectl apply -f ./argocd/application.yaml -n app-ns

sleep 5 
echo "argoCD server setup completed"

echo "getting argoCD server initial password to login"
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "initial_password"=$ARGOCD_PASSWORD ## e.g. for cli/gui initial loggin



##### install argocd cli locally outside of KinD:

# login from the cluster (argocd client)
# ARGOCD_PASSWORD is initial password after argoCD server deployed 
    argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --insecure 
# KinD uses self-signing certificate but for prod add CA and ingress in the chart for security 

#### will use helm to to install the app in its namespace
### here using the argoCD cli: same as above kubectl apply in argoCD server
## deploying argoCD on the app namespace 
## parameters same as application.yaml manifest:
#     argocd app create my-app \
#     --repo git@github.com/memor24/kubernetes-gitops-argocd.git
#     --path ../gitops/argocd \ ## path to /application.yaml
#     --dest-server https://kubernetes.default.svc \
#     --dest-namespace app-ns ## default ns is default


echo "argoCD server version:"
    argocd version --server
echo "argoCD client version is:"
    argocd version --client



# argocd cli initial commands
echo "synchronizing the app" 
    argocd app sync my-app  ## @ setup time, or if syncPolicy is set to manual!
echo "application status:"    
    argocd app get my-app

echo "Cleaning up the port forwarding"
kill $PORT_FORWARD_PID # or kill %1 , since it's the job #1 in the background


echo "argo CD installation and configuration completed successfully!"
echo "argo CD UI: https://localhost:8080"
echo "username: admin"
echo "initial password: $ARGOCD_PASSWORD"





