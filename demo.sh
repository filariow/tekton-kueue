#!/bin/bash

set -e

# setup kind cluster with tekton
./scripts/tekton_in_kind.sh

# install kyverno and kueue
./scripts/install-dependencies.sh

# create kyverno policies
kubectl apply -k kyverno

# create kueue's resources
kubectl apply -k kueue

# wait for kyverno clusterpolicies to be ready
kubectl get clusterpolicies -o name | \
  xargs -I{} kubectl wait --for='jsonpath={.status.conditions[?(@.type=="Ready")].status}=True' {}

# create pipelinerun
kubectl delete -f ./tekton/pipelinerun.yaml || true
kubectl delete --all -n my-ns workloads
kubectl apply -f ./tekton/pipelinerun.yaml

# watch resources
watch -n 1 "kubectl get pipelinerun -n my-ns && \
  kubectl get workloads -n my-ns && \
  kubectl get customrun -n my-ns"

