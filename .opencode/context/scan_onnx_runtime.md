# Scan ONNX Runtime Context

## Purpose
Tai lieu nay la source-of-truth cho scan architecture sau khi chuyen sang huong:
- Camera scan: ONNX local realtime.
- Gallery scan: backend API upload.

## Runtime split

### Camera (local)
- UI: `lib/features/scan/presentation/screens/camera_realtime_scan_screen.dart`
- Service: `lib/features/scan/domain/local_onnx_scan_service.dart`
- Pipeline:
  1. Khoi tao camera stream.
  2. Convert frame (`yuv420`/`bgra8888`/`nv21`) -> RGB image.
  3. Preprocess theo model config (size, normalize/raw).
  4. Tao tensor float32 (khong dung double).
  5. Chay ONNX inference local bang `session.run`.
  6. Softmax + top-k -> hien thi realtime.
  7. Mo `ScanResultScreen` voi ket qua local khi user can chi tiet.
- Realtime control:
  - Vao `ScanResultScreen` tu camera se tam dung infer realtime.
  - Back tu details ve camera se bat lai infer realtime.
- Detail enrichment:
  - Trong `ScanResultScreen` (flow camera), app goi backend scan API 1 lan de lay chi tiet thong tin cay.
  - Header tren result giu ket qua local (ten + confidence + framework), body du lieu uu tien tu API.

### Gallery (backend)
- UI trigger: `ScanTab` trong `lib/features/shop/presentation/screens/scan_tab.dart`
- Service: `lib/features/scan/domain/scan_service.dart`
- API: `lib/features/scan/data/scan_api.dart`
- Endpoint: `POST api/plant_detect?topk=5&two_pass=true`

## Model metadata & config
- Catalog: `assets/ml/configs/model_catalog.json`
- Policy: `assets/ml/configs/runtime_policy.json`
- Moi model co:
  - `model.onnx`
  - `config.json`
  - `labels.json`

## Supported model ids
- `organ_aware_switch_vit`
  - Input: `image` + `organ_prior`
  - Preprocess: `imagenet_norm`
- `efficientnetv2_segformer`
  - Input: `image`
  - Preprocess: `raw_01`
- `efficientnetv2_mask2former`
  - Input: `image`
  - Preprocess: `raw_01`
  - Marked non-realtime trong catalog
- `mobilenetv3large_segformer`
  - Input: `image`
  - Preprocess: `raw_01`
  - Default camera realtime model

## Persisted model selection
- Storage key: `scan.local.selected_model`
- Code: `lib/features/auth/data/storage_service.dart`

## Dependencies related to local scan
- `camera`
- `image`
- `onnxruntime`

## Constraints and risks
- Bundle size tang manh khi embed nhieu ONNX model.
- APK debug co the vuot kha nang cai tren emulator nho data partition.
- Camera plugin co the gay Kotlin incremental cache issue tren Windows khi root project va Pub cache khac drive.

## Suggested mitigations
- Release strategy: chi dong goi 1 model default, cac model khac tai on-demand.
- Build stability (Windows):
  - can nhac tat Kotlin incremental trong `android/gradle.properties` neu gap cache crash lap lai.
- QA strategy:
  - test camera realtime tren physical device.
  - test gallery API tren local + server base URL.
