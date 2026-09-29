#!/usr/bin/env bash
set -euo pipefail

# Run on your laptop. Fill in the VM details and the directory containing the
# Makefile on the VM (its programming/ directory is the bind-mount source).
VM_HOST="root@REPLACE_WITH_VM_IP"
VM_PORT="REPLACE_WITH_SSH_PORT"
VM_REPO_DIR="/REPLACE/WITH/VM/PATH/TO/WHAT_TO_SYNC"
LOCAL_DIR="REPLACE_WITH_LOCAL_DIR"

mkdir -p "$LOCAL_DIR"
rsync -av --progress -e "ssh -p ${VM_PORT}" \
  "${VM_HOST}:${VM_REPO_DIR}" \
  "${LOCAL_DIR}/"
