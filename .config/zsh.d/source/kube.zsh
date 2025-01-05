#  _  _____ ____
# | |/ ( _ ) ___|
# | ' // _ \___ \
# | . \ (_) |__) |
# |_|\_\___/____/
#

if ! _has kubectl; then
    return 1
fi

# Kubernetes
# ----------

# it's recommended to put kube config into a user-owned file in order to use kubectl without sudo
KUBECONFIG=""
[[ -d ~/.kube ]] && find ~/.kube -type f -maxdepth 1 | sort | while read -r file; do
    [[ "$file" =~ "config-"* ]] && KUBECONFIG+="$file:"
done
export KUBECONFIG

alias k='kubectl'

function kube_run_busybox() {
    namespace=$(kubectl config view --minify -o jsonpath='{..namespace}')
    echo "Running busybox in namespace '$namespace'"
    kubectl run --rm -i --tty busybox --image=busybox --restart=Never -- sh
}

function kube_kubelet_conf() {
    if ! curl -f http://127.0.0.1:8001/ &> /dev/null; then
        echo "Please ensure the kube proxy is serving on port 8001" >&2
        return 1
    fi

    node=$(fzf --header-lines=1 --header="Select a node to display its kubelet conf" --print0 <<< $(kubectl get nodes) | awk '{print $1}')
    if [[ -z $node ]]; then
        return 1
    fi
    curl -sSX GET http://127.0.0.1:8001/api/v1/nodes/$node/proxy/configz | jq .kubeletconfig
}

function kube_clean_evicted() {
    kubectl get pods -A -o json \
        | jq '.items[] | select((.status.reason == "Evicted") or (.status.phase == "Succeeded") or (.status.phase == "Failed")) | "kubectl delete pods \(.metadata.name) -n \(.metadata.namespace)"' \
        | xargs -n 1 $SHELL -c 2>/dev/null || echo "No evicted pods found"
}

# see https://github.com/junegunn/fzf/blob/master/ADVANCED.md#log-tailing
function pods() {
  command='kubectl get pods'
  fzf \
    --info=inline --layout=reverse --header-lines=1 \
    --height=80% \
    --prompt "$(kubectl config current-context | sed 's/-context$//')> " \
    --header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
    --bind "start:reload:$command" \
    --bind "ctrl-r:reload:$command" \
    --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
    --bind 'enter:execute:kubectl exec -it {1} -- bash' \
    --bind 'ctrl-o:execute:${EDITOR:-vim} <(kubectl logs --all-containers {1})' \
    --preview-window up:follow \
    --preview 'kubectl logs --follow --all-containers --tail=10000 {1}' "$@"
}

