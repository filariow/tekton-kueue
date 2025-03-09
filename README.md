# Tekton Kueue

This repo contains some experiments that integrate Tekton's PipelineRuns with Kueue without relying on PipelineRun's `spec.status` field.

Kyverno is used to implement the workflow.

## Try it

Hopefully, you should just run the `demo.sh` script.

## Workflow

```mermaid
flowchart TD
    pipelineRunCreated[PipelineRun is created]
    injectScheduleTask[Kyverno injects Schedule CustomRun]
    tektonCreatesCustomRun[Tekton creates a CustomRun and related kueue's Workload]
    kyvernoCreatesKueueWorkload[Kyverno creates the kueue's Workload for the CustomRun]
    kueueAdmitsWorkload[Kueue admits the Workload]
    kyvernoCompletesCustomRun[Kyverno completes the CustomRun]
    tektonSchedulesPRNextSteps[Tekton schedules PipelineRun's next tasks]

    pipelineRunCreated --> injectScheduleTask
    injectScheduleTask --> tektonCreatesCustomRun
    tektonCreatesCustomRun --> kyvernoCreatesKueueWorkload
    kyvernoCreatesKueueWorkload --> kueueAdmitsWorkload
    kueueAdmitsWorkload --> kyvernoCompletesCustomRun
    kyvernoCompletesCustomRun --> tektonSchedulesPRNextSteps
```

```mermaid
sequenceDiagram
    Alice->>APIServer: create PipelineRun
    APIServer->>Kyverno: mutate PipelineRun
    Kyverno->>APIServer: PipelineRun with injected CustomRun for scheduling
    APIServer-->>+Tekton: PipelineRun created
    Tekton->>APIServer: create PipelineRun's CustomRun
    APIServer-->>Kyverno: CustomRun created
    Kyverno->>APIServer: generate kueue's Workload for CustomRun
    APIServer-->>+Kueue: Workload created
    Kueue->>APIServer: update Workload's status as Admitted
    APIServer-->>Kyverno: Workload status changed
    Kyverno->>APIServer: mutate CustomRun status
    APIServer-->>+Tekton: CustomRun status updated as Succeeded
    Tekton->>APIServer: schedule next tasks
```

## Implementation details

* **PipelineRun is created**: [./tekton/pipelinerun.yaml](./tekton/pipelinerun.yaml)
* **Kyverno injects Schedule CustomRun**: [./kyverno/mutate-pipelinerun-clusterpolicy.yaml](./kyverno/mutate-pipelinerun-clusterpolicy.yaml)
* **Tekton creates a CustomRun**
* **Kyverno creates the kueue's Workload for the CustomRun**: [./kyverno/generate-workload-clusterpolicy.yaml](./kyverno/generate-workload-clusterpolicy.yaml)
* **Kueue admits the Workload**: [./kueue/](./kueue/)
* **Kyverno completes the CustomRun**: [./kyverno/mutate-customrun-workload.yaml](./kyverno/mutate-customrun-workload.yaml)
* **Tekton schedules PipelineRun's next tasks**
