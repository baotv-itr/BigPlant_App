# ONNX Local Scan Handover

This handover prepares Flutter assets and config only. No Dart code flow was changed.

## Objective

- Camera scan: ONNX local realtime.
- Gallery scan: keep backend API flow.
- Support selecting local model via persisted variable.

## Asset Structure

```text
assets/ml/
  configs/
    model_catalog.json
    runtime_policy.json
  models/
    organ_aware_switch_vit/
      model.onnx
      config.json
      labels.json
    efficientnetv2_segformer/
      model.onnx
      config.json
      labels.json
    efficientnetv2_mask2former/
      model.onnx
      config.json
      labels.json
    mobilenetv3large_segformer/
      model.onnx
      config.json
      labels.json
```

## Model Catalog

`assets/ml/configs/model_catalog.json` includes:

- default model id.
- camera mode and gallery mode.
- per-model paths for `model.onnx`, `config.json`, `labels.json`.
- per-model capability flag `supports_camera_realtime`.

## Runtime Policy

`assets/ml/configs/runtime_policy.json` includes:

- camera policy: `onnx_local_realtime`.
- gallery policy: `backend_api`.
- selected model storage key: `scan.local.selected_model`.
- fallback policy: backend fallback on local failure or low confidence.

## Per-Model Config

Each `assets/ml/models/<model_id>/config.json` includes:

- ONNX input/output signature.
- preprocessing mode (`imagenet_norm` or `raw_01`).
- top-k and two-pass defaults.
- exported checkpoint metadata and source trace.
- ONNX file checksum and byte size.

## Labels

Each `assets/ml/models/<model_id>/labels.json` includes class labels in index order used at inference output.

## Source of Truth

Assets were transferred from:

- `D:/Homework/BackEnd/ModelDetectApi/model/...`

Back-end model families mapped to Flutter model ids:

- `organ_aware_switch_vit`
- `efficientnetv2_segformer`
- `efficientnetv2_mask2former`
- `mobilenetv3large_segformer`

## Notes

- ONNX files are large; repository should use Git LFS for long-term storage.
- `efficientnetv2_mask2former` is marked non-realtime in catalog.
- Current default is `mobilenetv3large_segformer` for camera realtime.
