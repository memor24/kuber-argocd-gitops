# kubernetess-argocd-gitop
A Kubernetes cluster will be running with a flask app deployed on it similar to [kuber-helm-cicd](https://github.com/memor24/kuber-helm-cicd) repo. \
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
