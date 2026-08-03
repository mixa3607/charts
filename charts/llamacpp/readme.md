# Helm package for llamacpp

llama.cpp helm chart

## TL;DR

```console
helm install my-release oci://ghcr.io/mixa3607/charts/llamacpp
```

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+

## Models configuration

Models are configured via `.Values.models` which generates a presets INI file mounted to the container. The chart
automatically sets `LLAMA_ARG_MODELS_PRESET`
env var and mounts the generated file.

### Structure

```yaml
models:
  filename: llamacpp.ini     # default: models.ini
  defaults: # merged into every enabled preset
    log-colors: "on"
    metrics: true
    ...
  presets: # dict: key = model name (section name)
    model-name:
      enabled: true          # false = skip this preset entirely
      key: value
      ...
```

### Defaults merging

`defaults` are merged into each preset. Per-preset values take precedence (shallow merge — nested maps are replaced, not
deep-merged). No `[*]` section appears in the output.

### Template expressions

String values support Go template expressions via Helm's `tpl`:

```yaml
cache-ram: "{{ mul 16 1024 }}"   # → 16384
ctx-size: "{{ mul 78 1024 }}"    # → 79872
```

### Array handling

| Key               | Array behavior                | String fallback |
|-------------------|-------------------------------|-----------------|
| `device`          | join with `,` → `ROCm0,ROCm1` | pass through    |
| `tensor-split`    | join with `,` → `25,25,25,25` | pass through    |
| `fit-target`      | join with `,` → `GPU0,GPU1`   | pass through    |
| `override-tensor` | see below                     | pass through    |
| any other key     | each element on separate line | pass through    |

### override-tensor (structured format)

```yaml
override-tensor:
  - target: CPU
    tensors:
      - blk.0.ffn_down_exps.weight
      - blk.1.ffn_down_exps.weight
  - target: GPU1
    tensors: [ ]                    # empty → skipped
  - target: GPU2
    tensors:
      - blk.3.ffn_down_exps.weight
```

Renders as: `(blk.0.ffn_down_exps.weight|blk.1.ffn_down_exps.weight)=CPU,(blk.3.ffn_down_exps.weight)=GPU2`

String fallback also available: `override-tensor: "(a|b)=CPU"`

### Nested maps

Nested YAML maps are flattened with `-` separator:

```yaml
spec:
  type: draft-mtp
  draft:
    n-max: 3
    model: Qwen3.6-27B-MTP-ONLY-BF16.gguf
    device: CUDA2
image:
  max-tokens: 560
  min-tokens: 1120
```

Renders as:

```ini
samplers-temperature = 1
samplers-top-p = 0.95
samplers-top-k = 64
spec-type = draft-mtp
spec-draft-n-max = 3
spec-draft-model = Qwen3.6-27B-MTP-ONLY-BF16.gguf
spec-draft-device = CUDA2
image-max-tokens = 560
image-min-tokens = 1120
```

### YAML boolean gotcha

YAML interprets `on`, `off`, `yes`, `no` as booleans. Quote string values:

```yaml
log-colors: "on"   # string, correct
log-colors: on     # boolean true, wrong!
```

### Full example

```yaml
models:
  filename: llamacpp.ini
  defaults:
    log-colors: "on"
    metrics: true
    props: true
    slots: true
    jinja: true
    context-shift: false
    cache-idle-slots: true
    cache-ram: "{{ mul 8 1024 }}"
    batch-size: "{{ mul 2 1024 }}"
    ubatch-size: "{{ mul 2 1024 }}"
    offline: true
  presets:

    gemma-4-E4B-it:
      enabled: true
      hf-repo: unsloth/gemma-4-E4B-it-GGUF:Q8_0
      mmap: false
      device: none
      threads: 64
      cache-ram: 0
      ctx-size: "{{ mul 4 1024 }}"
      flash-attn: true
      samplers:
        temperature: 1.0
        top-p: 0.95
        top-k: 64

    DeepSeek-V4-Flash:
      enabled: false                      # not loaded
      hf-repo: bartowski/DeepSeek-V4-Flash-GGUF
      n-gpu-layers: all
      split-mode: layer
      threads: 32
      cache-ram: "{{ mul 16 1024 }}"
      ctx-size: "{{ mul 78 1024 }}"
      main-gpu: 0
      tensor-split: # array → joined with ","
        - 25
        - 25
        - 25
        - 25
      override-tensor: # structured format
        - target: CPU
          tensors:
            - blk.0.ffn_down_exps.weight
            - blk.0.ffn_up_exps.weight
            - blk.1.ffn_down_exps.weight
```
