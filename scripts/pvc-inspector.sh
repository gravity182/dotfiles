#!/bin/bash

# --- Configuration ---
UTILITY_POD_NAME="pvc-inspector-$(date +%s)" # Unique name for the utility pod
CONTAINER_IMAGE="ubuntu:latest"             # Image for the utility pod container
MOUNT_PATH="/mnt/pvc-data"                 # Mount path inside the utility pod

# --- Script Logic ---

# Check if a namespace was passed as a flag
NAMESPACE_FLAG=""
while getopts ":n:" opt; do
  case $opt in
    n)
      NAMESPACE_FLAG="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Determine the target namespace
TARGET_NAMESPACE=""
if [ -n "$NAMESPACE_FLAG" ]; then
  TARGET_NAMESPACE="$NAMESPACE_FLAG"
  echo "Using namespace specified by flag: $TARGET_NAMESPACE"
else
  echo "Fetching namespaces..."
  # List namespaces and pipe to fzf for interactive selection
  SELECTED_NAMESPACE=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name" | fzf --prompt="Select a namespace: " --height=10)

  if [ -z "$SELECTED_NAMESPACE" ]; then
    echo "No namespace selected. Exiting."
    exit 1
  fi
  TARGET_NAMESPACE="$SELECTED_NAMESPACE"
  echo "Selected namespace: $TARGET_NAMESPACE"
fi

# --- Fetch and Display PVC Information for Selection ---

echo "Fetching PVCs in namespace '$TARGET_NAMESPACE'..."

# Get PVCs in wide format, keeping the header
PVC_INFO=$(kubectl get pvc -n "$TARGET_NAMESPACE" -o wide)

# Check if any PVCs were found (besides the header)
if [ "$(echo "$PVC_INFO" | wc -l)" -le 1 ]; then
  echo "No PVCs found in namespace '$TARGET_NAMESPACE'. Exiting."
  exit 1
fi

# Use fzf with --header-lines option to use the first line as header
# We also need to capture the full selected line to extract the PVC name later
SELECTED_PVC_LINE=$(echo "$PVC_INFO" | fzf --prompt="Select a PVC: " --header-lines=1 --height=20)

if [ -z "$SELECTED_PVC_LINE" ]; then
  echo "No PVC selected. Exiting."
  exit 1
fi

# Extract the PVC name from the selected line (assuming name is the first column)
# We use awk to get the first field of the selected line
SELECTED_PVC=$(echo "$SELECTED_PVC_LINE" | awk '{print $1}')

if [ -z "$SELECTED_PVC" ]; then
    echo "Failed to extract PVC name from selection. Exiting."
    exit 1
fi

echo "Selected PVC: $SELECTED_PVC"

# --- Generate and Apply Utility Pod YAML ---

# Generate the utility pod YAML dynamically
UTILITY_POD_YAML=$(cat <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: $UTILITY_POD_NAME
  namespace: $TARGET_NAMESPACE
spec:
  volumes:
  - name: target-pvc-storage
    persistentVolumeClaim:
      claimName: $SELECTED_PVC
  containers:
  - name: inspector
    image: $CONTAINER_IMAGE
    command: ["sleep", "infinity"]
    volumeMounts:
    - name: target-pvc-storage
      mountPath: $MOUNT_PATH
    securityContext:
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
EOF
)

echo "Creating utility pod '$UTILITY_POD_NAME' in namespace '$TARGET_NAMESPACE'..."

# Apply the generated YAML
echo "$UTILITY_POD_YAML" | kubectl apply -f -

# Wait for the pod to be ready
echo "Waiting for utility pod '$UTILITY_POD_NAME' in namespace '$TARGET_NAMESPACE' to be ready..."
kubectl wait --for=condition=ready pod/$UTILITY_POD_NAME -n "$TARGET_NAMESPACE" --timeout=300s

if [ $? -ne 0 ]; then
  echo "Error: Utility pod did not become ready."
  kubectl logs $UTILITY_POD_NAME -n "$TARGET_NAMESPACE"
  kubectl delete pod $UTILITY_POD_NAME -n "$TARGET_NAMESPACE" --ignore-not-found=true
  exit 1
fi

# Determine the shell command to execute
# We need to execute 'cd <mount_path> && <your_preferred_shell>'
# This ensures we change directory first, then start the shell.
# Using 'exec' replaces the current process with the shell, preserving the
# exit code properly.
CONTAINER_CMD="/bin/bash"

echo "Utility pod is ready. Spawning shell..."

# Enter the shell inside the utility pod
kubectl exec -it $UTILITY_POD_NAME -n "$TARGET_NAMESPACE" -- "$CONTAINER_CMD"

# --- Cleanup ---
echo "Exiting shell. Cleaning up utility pod '$UTILITY_POD_NAME' in namespace '$TARGET_NAMESPACE'..."
kubectl delete pod $UTILITY_POD_NAME -n "$TARGET_NAMESPACE" --ignore-not-found=true --wait=false

echo "Cleanup complete."
