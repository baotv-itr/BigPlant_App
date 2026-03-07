# Skill: auth-flow

## Scope
Login, register, verify OTP, forgot password, reset password, token verify.

## Endpoints
- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/email_verification/`
- `POST /api/email_verification/verify`
- `POST /api/forgot_password/`
- `POST /api/forgot_password/check_valid_digit`
- `POST /api/forgot_password/reset`
- `GET /api/auth/verify`

## Must-have checks
- Validation input local truoc khi call API.
- Luu/xoa `token` + `user_id` qua `StorageService`.
- Handle loading/error state ro rang.
- Dieu huong route dung sau thanh cong.
