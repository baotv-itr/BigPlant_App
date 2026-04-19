# Skill: api-integration

## Scope
Dong bo va tich hop API cho auth/shop/scan.

## Guidelines
- Hien tai app dung `ApiConstants.baseUrl` cho ca auth/shop/scan.
- Ghi ro request/response schema cho moi endpoint.
- Chuan hoa message loi cho UX.
- Co timeout phu hop theo loai request.

## Scan-specific contract (current)
- Endpoint: `POST api/plant_detect?topk=5&two_pass=true`
- Content type: multipart/form-data
- File field: `file`
- Auth header: `Authorization: Bearer <token>` neu token ton tai.
- Gallery flow goi API scan truc tiep.
- Camera realtime local khong goi API trong luc dang stream frame.
- Khi user vao `Open result details` tu camera realtime, app goi API scan 1 lan de enrich du lieu details.

## Validation checklist
- Success status handling.
- Non-2xx handling + user-facing error.
- Mapping JSON an toan (null/type mismatch).
- Token header duoc gan dung luc.
- Gallery scan van call API dung contract.
- Camera realtime chi call API o buoc details enrichment, khong call khi stream frame.
