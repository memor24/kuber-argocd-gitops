# kubernetes-manifests-gitop
A Kubernetes cluster will be running with a flask app deployed on it. \
\
Here we want to make sure the app cluster is in sync with the single source of truth which is this git repo. This is called GitOps and is done using an ArgoCD cluster.

### Prerequisites

- Docker
- Kind (Kubernetes in Docker)
- Cluster with namespaces for the app and the argocd \
  \
Here, I have used the above, but can also use seperate clusters for the app and the argocd and refer to them using cluster endpoints:
- App cluster(s)
- ArgoCD server cluster 
- ArgoCD CLI (local client) \
In that case, we may have to use a loadbalancer and DNS to access external clusters as destonation in application.yml configuration.

ArgoCD uses git and kubectl under the hood to do app deployment the GitOps way. 

*************************************************************
In prod, use Kustomize. In dev environment, use this one time manual steps:
\
Make sure Docker engine is running:
```
kind create cluster --name my-cluster --config "./gitops/cluster-config.yaml"
docker ps -q --filter "name=control-plane"
```

Install, configure and run argoCD --namespace argocd on the empty cluster:
```
docker exec "$CP_CONTAINER" bash -c \ "
kubectl create namespace "argocd" && \
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml && \
kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=argocd-server -n argocd "           
```
For dev environment, use port forwarding in a new terminal to access ArgoCD:
```
kubectl port-forward svc/argocd-server -n argocd 8080:443 & PORT_FORWARD_PID=$!
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
Use that initial password to login to ArgoCD via `https://localhost:8080` or use ArgoCD CLI to interact with it.
In prod, you want to use loadbalancing and DNS to have a stable ArgoCD access.

Initial deployment of the app on the app namespace in the cluster is done by running application.yaml
