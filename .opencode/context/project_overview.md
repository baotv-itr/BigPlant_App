# BigPlant Project Overview

## Product intent
- BigPlant la app Flutter gom 2 gia tri chinh:
  - E-commerce cho cay/chau.
  - AI scan cay tu anh de nhan dien + hien thi thong tin va map phan bo.

## Current architecture (from source)
- Entry: `lib/main.dart` -> `lib/app.dart`.
- Core modules: `lib/core`.
- Feature modules:
  - `lib/features/auth`
  - `lib/features/shop`
  - `lib/features/scan`

## Main user flow
1. Splash kiem tra token -> hop le vao main shell, khong hop le vao login.
2. Auth flow: login/register/verify otp/forgot/reset.
3. Sau auth thanh cong vao shell 4 tab:
   - Home
   - Scan
   - Cart
   - Settings

## API boundaries
- Auth/shop base URL: `ApiConstants.baseUrl`.
- Scan base URL rieng: `ApiConstants.baseScanUrl`.
- Scan API la multipart upload image, co fallback nhieu endpoint.

## Current status notes
- Home/Cart hien la mock data + UI first.
- Scan da chay luong camera/gallery -> upload -> parse ket qua -> render map.
- Localization co `vi/en`.
- Database architecture da duoc bo sung tai `context/database_architecture.md`.
