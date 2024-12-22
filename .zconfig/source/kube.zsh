if ! _has kubectl; then
    return 1
fi

# Kubernetes
# ----------

# it's recommended to put kube config into a user-owned file in order to use kubectl without sudo
KUBECONFIG=""
find ~/.kube -type f -maxdepth 1 | sort | while read -r file; do
    [[ "$file" =~ "config-*" ]] && KUBECONFIG+="$file:"
done
export KUBECONFIG

alias k='kubectl'

function kube_run_busybox() {
    kubectl run -it busybox --image=busybox --restart=Never
}

function kube_clean_evicted() {
    kubectl get pods -A -o json \
        | jq '.items[] | select((.status.reason == "Evicted") or (.status.phase == "Succeeded")) | "kubectl delete pods \(.metadata.name) -n \(.metadata.namespace)"' \
        | xargs -n 1 $SHELL -c 2>/dev/null || echo "No evicted pods found"
}

