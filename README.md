# kubernetes-gitops-argocd
A Kubernetes cluster is running already with a flask app deployed on it from [kuber-helm-cicd repo](https://github.com/memor24/kuber-helm-cicd), and here we want to make sure the cluster (and the app) are in sync with the single source of truth which is this git repo. This is called GitOps and is done using ArgoCD. A `KUBECONFIG` secret might be needed for kubectl or ArgoCD access to the cluster.

### Prerequisites

- Docker
- Kind (Kubernetes in Docker) or any running cluster
- Kubectl
- Helm (optional; for testing charts manually or in --dry-run)
- ArgoCD
