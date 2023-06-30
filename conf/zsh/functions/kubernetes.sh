#!/usr/bin/env bash

# Deletes empty namespaces.
# Requires one arg, which is the prefix start string.
kns-cleanup() {
    if [[ $# -eq 0 ]]; then
        echo "namespace prefix filter is required"
        return
    fi

    ns=()
    while IFS='' read -r line; do ns+=("$line"); done < <(kubectl get ns --no-headers -o custom-columns=":metadata.name" | grep "^$1")

    if [[ "${#ns[@]}" -eq 0 ]]; then
        echo "No namespaces found with filter \"${1}\""
        return
    else
        echo "Looking for empty namespaces..."
        for n in "${ns[@]}" ; do
            if ! [[ "$(kubectl get deployment -n "${n}" -o name)" ]]; then
                echo "Deleting: ${n}"
                kubectl delete ns "${n}"
            fi
        done
    fi
}
