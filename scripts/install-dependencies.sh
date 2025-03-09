#!/bin/bash

# install kueue
helm upgrade --install kueue oci://registry.k8s.io/charts/kueue \
  --version=v0.10.2 \
  --namespace  kueue-system \
  --create-namespace \
  --wait --timeout 300s

# install kyverno
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=1 \
  --set backgroundController.replicas=1 \
  --set cleanupController.replicas=1 \
  --set reportsController.replicas=1 \
  --set features.dumpPatches.enabled=true

kubectl rollout status -n kyverno deployment kyverno-admission-controller
