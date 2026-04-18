# Skill: release-checklist

## Pre-release
- Run test va static analyze.
- Verify auth flow E2E.
- Verify 4 tab navigation sau auth.
- Verify scan camera local realtime tren device that.
- Verify scan gallery backend tren local/server URL.
- Verify map render va fallback state.

## ML/Build review
- Kiem tra `assets/ml/configs/model_catalog.json` va `runtime_policy.json` khop voi code.
- Kiem tra dung luong model ONNX va APK size truoc release.
- Neu install emulator fail, kiem tra dung luong `/data` partition.
- Tren Windows, neu gap Kotlin incremental cache crash voi `camera_android_camerax`, can nhac tat incremental compile.

## Config review
- Kiem tra `useLocalApi` theo moi truong.
- Kiem tra endpoint production co dung schema.

## Documentation
- Cap nhat `.opencode/context/project_overview.md` neu co thay doi flow.
- Cap nhat `.opencode/context/scan_onnx_runtime.md` neu doi model/camera policy.
- Cap nhat skill lien quan neu co contract moi.
