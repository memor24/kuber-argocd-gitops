# /bin/bash

$ARGOCD_NAMESPACE=argocd
$APP_NAMESPACE=app-ns
$HELM_CHART_DIR=./cluster/myapp-helm-chart

# install argoCD and its cli
echo "Installing argoCD"
kubectl create namespace $ARGOCD_NAMESPACE
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "waiting for argoCD to get ready"
kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=argocd-server -n $ARGOCD_NAMESPACE

# configure argoCD
echo "Configuring argoCD"
echo "Setting up port forwarding to access argoCD locally"
kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443 & PORT_FORWARD_PID=$!

echo "Getting argoCD server password"
ARGOCD_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "initial_password"=$ARGOCD_PASSWORD # e.g. for gui loggin and changing it

echo "Logging into argoCD"
argocd login --username admin --password "$ARGOCD_PASSWORD" --insecure # add CA and ingress in the chart for security 

echo "Creating the application namespace"
kubectl create namespace "$APP_NAMESPACE"

echo "Creating the app in argoCD and deploying the application with Helm Chart "
argocd app create my-app-argocd \
--repo git@github.com:memor24/kubernetes-gitops-argocd.git
--path ../gitops/cluster \
--dest-server https://kubernetes.default.svc \
--dest-namespace default

echo "Syncing the application"
argocd app sync my-app

echo "Cleaning up the port forwarding"
kill $PORT_FORWARD_PID # kill %1

echo "ArgoCD setup and application deployment completed"






