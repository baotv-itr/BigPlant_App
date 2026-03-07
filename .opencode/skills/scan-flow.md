# Skill: scan-flow

## Scope
Scan tab + scan result: camera/gallery -> upload -> parse -> map.

## Current mechanics
- Chon anh bang `image_picker`.
- Upload multipart voi Bearer token neu co.
- Thu nhieu endpoint + nhieu ten file field de tuong thich backend.
- Parse response linh hoat sang `PlantScanResult`.
- Hien map marker bang `flutter_map` neu co distribution points.

## Must-have checks
- Xu ly timeout/network error.
- Khong crash khi response thieu field.
- Co fallback khi khong co map data.

## Open direction
- Bo sung cac tinh nang scan khac (dang cap nhat theo roadmap).
