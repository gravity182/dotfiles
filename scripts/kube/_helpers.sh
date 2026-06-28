#!/usr/bin/env bash

kube_die() {
    echo "Error: $*" >&2
    exit 1
}

kube_require_cmd() {
    local cmd="$1"

    if ! command -v "$cmd" &> /dev/null; then
        kube_die "$cmd is not installed or not in PATH"
    fi
}

kube_require_context() {
    if ! kubectl config current-context &> /dev/null; then
        kube_die "No valid kubectl context found"
    fi
}

kube_select_namespace() {
    local selected_namespace

    selected_namespace=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select a namespace: " --height=10)
    if [[ -z "$selected_namespace" ]]; then
        echo "No namespace selected. Exiting." >&2
        return 130
    fi

    printf '%s\n' "$selected_namespace"
}

kube_sanitize_dns_label() {
    local input="$1"
    local max_len="${2:-63}"
    local sanitized

    sanitized=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9-]+/-/g; s/^-+//; s/-+$//')
    sanitized="${sanitized:0:$max_len}"

    while [[ "$sanitized" == *- ]]; do
        sanitized="${sanitized%-}"
    done

    printf '%s\n' "$sanitized"
}

kube_timestamp() {
    date +%Y%m%d-%H%M%S
}

kube_unique_name() {
    local prefix="$1"
    local max_len="${2:-63}"
    local suffix
    local prefix_max
    local sanitized_prefix

    suffix="$(kube_timestamp)"
    prefix_max=$((max_len - 1 - ${#suffix}))
    if [[ "$prefix_max" -lt 1 ]]; then
        prefix_max=1
    fi

    sanitized_prefix=$(kube_sanitize_dns_label "$prefix" "$prefix_max")
    if [[ -z "$sanitized_prefix" ]]; then
        kube_die "Failed to create a valid Kubernetes name from: $prefix"
    fi

    printf '%s-%s\n' "$sanitized_prefix" "$suffix"
}
