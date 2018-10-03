# Kubernetes plugin for drone.io

This plugin is a fork of [drone-kubernetes](https://github.com/honestbee/drone-kubernetes) with some changes.

# Usage

Add your config to .drone.yml

```
  deploy:
    image: uitk23009/drone-k8s-script
    pull: true # force to pull image
    kubernetes_cmd:
      - kubectl -n default apply -f test-deployment.yaml
      - kubectl -n default apply -f test-service.yaml
      - kubectl get all
    secrets: [kubernetes_server, kubernetes_cert, kubernetes_token]

```

Using kubesec.sh to get KUBERNETES_SERVER, KUBERNETES_CERT, KUBERNETES_TOKEN

```
$ bash kubesec.sh list -d username@hostip 

```
