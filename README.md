# kubernetes-gitops-argocd
A Kubernetes cluster will be running with a flask app deployed on it similar to [kuber-helm-cicd](https://github.com/memor24/kuber-helm-cicd) repo. \
\
Here we want to make sure the app cluster is in sync with the single source of truth which is this git repo. This is called GitOps and is done using an ArgoCD cluster. \

### Prerequisites

- Docker
- Kind (Kubernetes in Docker)
- App cluster
- ArgoCD server cluster
- ArgoCD CLI (local client) 
* ArgoCD uses git, kubectl, helm, etc under the hood to do app deployment and GitOps.
