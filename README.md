# Kubernetes plugin for drone<i></i>.io

This plugin is a fork of [honestbee/drone-kubernetes](https://github.com/honestbee/drone-kubernetes) with some changes.

## Usage

Add your config to .drone.yml

```yaml
  deploy:
    image: uitk23009/drone-k8s-script
    pull: true # force to refresh image
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

Using kubesec.sh to add KUBERNETES_SERVER, KUBERNETES_CERT, KUBERNETES_TOKEN

1. Add your ```DRONE_SERVER``` and ```DRONE_TOKEN``` to kubesec.sh,
   you can find token in ```http://<drone-server>/account/token``` page

```bash
# kubesec.sh

exe eval "export DRONE_SERVER=https://<drone-server>"
exen eval "export DRONE_TOKEN=your_token"

```

2. Execute kubesec<i></i>.sh
```
$ bash kubesec.sh add -d username@hostip -i uitk23009/drone-k8s-script -r uitk23009/test-repository

```


## Build your own image

You can adjust update<i></i>.sh and build your own image

* build image
```
$ docker build -t &lt;your_register_id&gt;/&lt;repository_name&gt;
```

* publish image to registry e.g. dockerhub
```
$ docker push &lt;your_register_id&gt;/&lt;repository_name&gt;
```

* Change .drone.yml deploy image to your own

```yaml
# .drone.yml

deploy:
    image: &lt;your_register_id&gt;/&lt;repository_name&gt;
    pull: true # force to refresh image
    ...
```
