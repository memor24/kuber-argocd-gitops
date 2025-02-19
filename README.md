# kubernetes-helm-gitops
A node app is deployed on Kubernetes using helm charts:
- **deployment helm chart:** 
- **secret management:** creates and applies [regcred secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) to be used in deployment. It can be manaaged by kubectl, or a second helm chart can be created for secret management too! 

GHCR is used instead of DockerHub for container registry. A `GITHUB_TOKEN` is applied for package read/write access to GHCR.
GitOps is done using ArgoCD. A `KUBECONFIG` secret might be needed for kubectl or ArgoCD access to the cluster.

### Prerequisites

- Docker
- Kind (Kubernetes in Docker)
- Kubectl
- Helm
- ArgoCD
