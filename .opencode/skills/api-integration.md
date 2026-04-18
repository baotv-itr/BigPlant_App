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
- Camera realtime local khong goi API scan (tru khi bo sung fallback logic sau nay).

## Validation checklist
- Success status handling.
- Non-2xx handling + user-facing error.
- Mapping JSON an toan (null/type mismatch).
- Token header duoc gan dung luc.
- Gallery scan van call API dung contract, camera khong call API ngoai y muon.
