# Skill: scan-flow

## Scope
Scan tab + scan result voi split flow:
- Camera -> ONNX local realtime.
- Gallery -> backend API upload.

## Current mechanics (must follow)

### Camera flow
- Entry button tai `ScanTab` mo `CameraRealtimeScanScreen`.
- Frame streaming tu `camera` plugin.
- Inference local qua `LocalOnnxScanService`.
- Frame convert ho tro `yuv420` / `bgra8888` / `nv21`.
- Tensor input phai la float32 (`Float32List`) de khop ONNX `tensor(float)`.
- Model duoc chon tu catalog + persist qua `scan.local.selected_model`.
- Ket qua realtime hien top-1 confidence; mo chi tiet qua `ScanResultScreen`.
- Khi bam `Open result details`: tam dung quet realtime, vao details, back lai thi quet tiep.
- Trong `ScanResultScreen` (vao tu camera), app goi API de lay thong tin chi tiet va do vao body; header van giu ket qua local.

### Gallery flow
- Dung `image_picker` lay anh.
- Goi `ScanService.scanPlant` -> `ScanApi.scanPlant`.
- Multipart field la `file`, endpoint co query `topk=5&two_pass=true`.
- Parse linh hoat vao `PlantScanResult`, hien map neu co distribution points.

## Files to check when modifying scan
- `lib/features/shop/presentation/screens/scan_tab.dart`
- `lib/features/scan/presentation/screens/camera_realtime_scan_screen.dart`
- `lib/features/scan/domain/local_onnx_scan_service.dart`
- `lib/features/scan/domain/scan_service.dart`
- `lib/features/scan/data/scan_api.dart`
- `lib/features/scan/domain/models/plant_scan_result.dart`
- `assets/ml/configs/model_catalog.json`
- `assets/ml/configs/runtime_policy.json`

## Must-have checks
- Camera stream khong crash khi doi model hoac rotate camera.
- Local inference fail phai hien error an toan, khong treo UI.
- Khi dang o `ScanResultScreen`, camera realtime khong tiep tuc infer nen.
- Back tu `ScanResultScreen` ve camera thi realtime infer phai resume.
- Gallery upload fail phai tra thong diep ro rang.
- Parse response khong crash khi field thieu/sai type.
- `ScanResultScreen` van render du placeholders neu data rong.

## QA scenarios
- Camera realtime voi model default (`mobilenetv3large_segformer`).
- Camera switch model (>=2 model realtime).
- Gallery upload thanh cong + that bai (timeout/network).
- Response co/khong co distribution map.

## Non-functional notes
- APK size lon do ONNX assets; can quan tri release strategy.
- Emulator co data partition nho de gap loi install du build thanh cong.
