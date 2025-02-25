# kubernetes-gitops-argocd
A Kubernetes cluster will be running with a flask app deployed on it similar to [kuber-helm-cicd](https://github.com/memor24/kuber-helm-cicd) repo. \
\
Here we want to make sure the cluster (and the app) are in sync with the single source of truth which is this git repo. This is called GitOps and is done using ArgoCD. \
\
(A KUBECONFIG secret might be needed for kubectl or ArgoCD access to the cluster.) \
\
Here, we use `helm` to deploy the app to the cluster and also to install argoCD in the cluster.
### Prerequisites

- Docker
- Kind (Kubernetes in Docker) or any running cluster
- Kubectl
- Helm (optional; for testing manually, or for easier installation of argocd itself)
- ArgoCD
