#!/bin/bash

get_k8s_secrets() {
    server=$(grep "server" /etc/kubernetes/admin.conf | awk '{print $2}')
    token_name=$(kubectl get -n default secret | grep "default" | awk '{print $1}')
    crt=$(kubectl get secret -n default $token_name -o yaml | egrep 'ca.crt' | awk '{print $2}')
    token=$(kubectl describe secret -n default $token_name | grep 'token:' | awk '{print $2}')
    echo $server $crt $token
}

usage="Get k8s master info and add to drone secret

Usage: bash $0 <command> [-d domain] [-i image] [-r repository]

e.g. bash kubesec.sh -d do -i sh4d1/drone-kubernetes -r prolink-2018-admin

Commands:
  add                   Add Kubernetes info to Drone
  list                  List Kubernetes info

Options:
  -d domain             Master domain info(required),
                        you can pass domain name e.g. bandwagon (need set ssh config),
                        or domain login info e.g. user@hostip.
  -i image name         Drone secret bind image e.g. sh4d1/drone-kubernetes.
  -r repository name    Drone secret bind repository e.g. prolink-2018-admin."

# echo current execute command
exe() { echo "${@/eval/}" ; "$@" ; }

# echo current execute command and add new line
exen() { echo -e "${@/eval/}\n" ; "$@" ; }

action=$1; shift

while getopts 'd:i:r:' arg; do
    case $arg in
        h)  echo "$usage"; exit;;
        d)  domain="$OPTARG";;
        i)  image="$OPTARG";;
        r)  repository="$OPTARG";;
        ?)  echo "$usage"; exit;;
    esac
done

if [ $OPTIND == 1 ]; then
    echo "$usage"
    exit
fi

if [ -z $domain ]; then
    echo "Error: Invalid or missing domain. e.g. do or user@hostip"
    exit
fi

if [ -z $image ] && [ "$1" == "add" ]; then
    echo "Error: Invalid or missing image. e.g. octocat/hello-world."
    exit
fi

if [ -z $repository ] && [ "$1" == "add" ]; then
    echo "Error: Invalid or missing image. e.g. aiwill/prolink-2018-admin."
    exit
fi


if [ ! -f /usr/local/bin/drone ]; then
    echo "Please install drone cli first."
else
    RESULT=$(ssh $domain "$(typeset -f get_k8s_secrets); get_k8s_secrets")

    if [[ -z $RESULT ]]; then
        echo "Error: didn't find kubernetes configure file in host."
    else
        if [ $action == "add" ]; then
            # Export Drone server address
            echo -e "Export Drone server address."
            exe eval "export_your_drone_server"
            exen eval "export_your_drone_token"

            # Split result by ' '
            echo -e "Add Drone secrets."
            IFS=' ' read -ra ADDR <<< "$RESULT"
            INDEX=1
            for i in "${ADDR[@]}"; do
                if [ $INDEX == 1 ]; then
                    exen eval "drone secret add --image $image -repository $repository -name KUBERNETES_SERVER -value $i"
                    INDEX=$((INDEX + 1))
                elif [ $INDEX == 2 ]; then
                    exen eval "drone secret add --image $image -repository $repository -name KUBERNETES_CERT -value $i"
                    INDEX=$((INDEX + 1))
                else
                    exen eval "drone secret add --image $image -repository $repository -name KUBERNETES_TOKEN -value $i"
                fi
            done
        elif [ $action == "list" ]; then
            # Split result by ' '
            echo -e "List Kubernetes secrets."
            IFS=' ' read -ra ADDR <<< "$RESULT"
            echo -e "SERVER: ${ADDR[0]}\n"
            echo -e "CRT: ${ADDR[1]}\n"
            echo -e "TOKEN: ${ADDR[2]}\n"
        fi
    fi
fi
