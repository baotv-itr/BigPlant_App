# BigPlant Database Architecture

## Problem
- He thong hien tai da co 3 module lon (`auth`, `shop`, `scan`) nhung DB chua duoc chot, dan den kho dong bo API, kho mo rong flow mua hang va kho luu lich su scan.
- User da co ban phac thao bang `Users`, nhung chua du boundary auth/session/otp va chua cover luong `cart -> order -> payment -> shipment`.

## Current state (from source)
- Auth API dang dung cac endpoint:
  - `api/auth/register` gui `user_name`, `email`, `phone_number`, `password`.
  - `api/auth/login` tra ve `token` + `user_id`.
  - OTP flow: `api/email_verification/*` va `api/forgot_password/*`.
- Shop UI hien la mock data (home/cart/settings) nhung da ro nghiep vu can co:
  - San pham co category, price, rating, variant.
  - Gio hang co quantity, subtotal, delivery, total.
  - Co action checkout.
- Scan flow da production-like:
  - Upload anh multipart.
  - Nhan ket qua taxonomy (`family/order/genus/species`), cong dung, uu diem, description.
  - Co distribution area + distribution points (lat/lng), confidence.
- Settings da the hien can luu preference: `notify_deals`, `notify_tips`, `language`.

## Proposal

### 1) Chon kieu DB va boundary
- DB chinh: PostgreSQL (khuyen nghi 16+), su dung `jsonb` cho payload linh hoat.
- Kien truc theo bounded context:
  - `Auth`: users, otp, sessions.
  - `Shop`: catalog, inventory, cart, order, payment, shipment, review.
  - `Scan`: plant knowledge + scan history + matching.
- Neu scan model/service tach server rieng, scan DB van chung Postgres de bao toan user history va analytics; model server chi tra response.

### 2) Logical schema (DBML)

```dbml
Enum auth_provider {
  local
  google
}

Enum user_gender {
  male
  female
  other
  unknown
}

Enum otp_purpose {
  register_verify
  forgot_password
}

Enum otp_status {
  pending
  verified
  expired
  consumed
}

Enum cart_status {
  active
  converted
  abandoned
}

Enum order_status {
  pending_payment
  paid
  processing
  shipping
  completed
  cancelled
  refunded
}

Enum payment_method {
  cod
  vnpay
  momo
  stripe
  bank_transfer
  wallet
}

Enum payment_status {
  pending
  authorized
  captured
  failed
  cancelled
  refunded
  partially_refunded
}

Enum shipment_status {
  pending
  packed
  handed_over
  in_transit
  delivered
  failed
  returned
}

Enum product_type {
  plant
  pot
  accessory
  service
}

Enum inventory_tx_type {
  import
  reserve
  release
  deduct
  adjust
  return_in
  return_out
}

Enum scan_source {
  camera
  gallery
  api
}

Enum scan_status {
  success
  failed
  timeout
}

Enum match_source {
  ml_model
  manual_rule
  user_override
}

Table users {
  user_id bigserial [pk, increment]
  mongo_object_id varchar(48) [unique, note: 'legacy _id from mongodb']

  user_name varchar(100) [not null, unique]
  full_name varchar(120)
  email varchar(160) [not null, unique]
  phone_number varchar(20)
  password_hash varchar(255)
  date_of_birth date
  gender user_gender [not null, default: 'unknown']

  google_id varchar(100) [unique]
  provider auth_provider [not null, default: 'local']
  photo_url text
  score int [not null, default: 0]

  email_verified_at timestamptz
  is_active boolean [not null, default: true]
  last_login_at timestamptz

  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (email)
    (phone_number)
    (created_at)
  }
}

Table user_notification_preferences {
  user_id bigint [pk, ref: > users.user_id]
  notify_deals boolean [not null, default: true]
  notify_plant_tips boolean [not null, default: true]
  language_code varchar(8) [not null, default: 'vi']
  updated_at timestamptz [not null, default: `now()`]
}

Table auth_sessions {
  session_id bigserial [pk, increment]
  user_id bigint [not null, ref: > users.user_id]

  access_token_hash varchar(255) [not null]
  refresh_token_hash varchar(255)
  device_id varchar(120)
  device_name varchar(200)
  ip_address varchar(64)
  user_agent varchar(255)

  expires_at timestamptz [not null]
  revoked_at timestamptz
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (user_id, revoked_at)
    (expires_at)
  }
}

Table OTP {
  otp_id bigserial [pk, increment]
  user_id bigint [ref: > users.user_id]
  email varchar(160) [not null]

  purpose otp_purpose [not null]
  otp_code_hash varchar(255) [not null]
  status otp_status [not null, default: 'pending']
  resend_count int [not null, default: 0]

  expires_at timestamptz [not null]
  verified_at timestamptz
  consumed_at timestamptz

  request_ip varchar(64)
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (email, purpose, status)
    (user_id, purpose, created_at)
  }
}

Table addresses {
  address_id bigserial [pk, increment]
  user_id bigint [not null, ref: > users.user_id]

  recipient_name varchar(120) [not null]
  recipient_phone varchar(20) [not null]
  line1 varchar(255) [not null]
  line2 varchar(255)
  ward varchar(120)
  district varchar(120)
  city varchar(120) [not null]
  country varchar(80) [not null, default: 'VN']
  postal_code varchar(20)

  is_default boolean [not null, default: false]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (user_id, is_default)
  }
}

Table product_categories {
  category_id bigserial [pk, increment]
  parent_id bigint [ref: > product_categories.category_id]
  name varchar(120) [not null]
  slug varchar(160) [not null, unique]
  description text
  is_active boolean [not null, default: true]
  sort_order int [not null, default: 0]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]
}

Table products {
  product_id bigserial [pk, increment]
  category_id bigint [ref: > product_categories.category_id]

  sku varchar(64) [not null, unique]
  product_type product_type [not null, default: 'plant']
  name varchar(180) [not null]
  slug varchar(220) [not null, unique]
  short_description varchar(255)
  description text
  care_level varchar(32)

  rating_avg numeric(3,2) [not null, default: 0]
  rating_count int [not null, default: 0]

  is_active boolean [not null, default: true]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (category_id, is_active)
    (name)
  }
}

Table product_variants {
  variant_id bigserial [pk, increment]
  product_id bigint [not null, ref: > products.product_id]

  variant_sku varchar(64) [not null, unique]
  variant_name varchar(120) [not null]
  attributes jsonb
  price numeric(12,2) [not null]
  compare_at_price numeric(12,2)
  weight_gram int

  is_default boolean [not null, default: false]
  is_active boolean [not null, default: true]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (product_id, is_active)
    (price)
  }
}

Table product_images {
  image_id bigserial [pk, increment]
  product_id bigint [ref: > products.product_id]
  variant_id bigint [ref: > product_variants.variant_id]
  image_url text [not null]
  alt_text varchar(255)
  sort_order int [not null, default: 0]
  is_primary boolean [not null, default: false]
  created_at timestamptz [not null, default: `now()`]
}

Table variant_inventory {
  variant_id bigint [pk, ref: > product_variants.variant_id]
  available_qty int [not null, default: 0]
  reserved_qty int [not null, default: 0]
  sold_qty int [not null, default: 0]
  updated_at timestamptz [not null, default: `now()`]
}

Table inventory_transactions {
  inventory_tx_id bigserial [pk, increment]
  variant_id bigint [not null, ref: > product_variants.variant_id]
  tx_type inventory_tx_type [not null]
  quantity int [not null]
  reference_type varchar(50)
  reference_id bigint
  note text
  created_by bigint [ref: > users.user_id]
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (variant_id, created_at)
    (reference_type, reference_id)
  }
}

Table carts {
  cart_id bigserial [pk, increment]
  user_id bigint [not null, ref: > users.user_id]
  status cart_status [not null, default: 'active']

  subtotal_amount numeric(12,2) [not null, default: 0]
  discount_amount numeric(12,2) [not null, default: 0]
  shipping_amount numeric(12,2) [not null, default: 0]
  total_amount numeric(12,2) [not null, default: 0]

  expires_at timestamptz
  converted_to_order_id bigint
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (user_id, status)
    (expires_at)
  }
}

Table cart_items {
  cart_item_id bigserial [pk, increment]
  cart_id bigint [not null, ref: > carts.cart_id]
  variant_id bigint [not null, ref: > product_variants.variant_id]

  quantity int [not null, default: 1]
  unit_price numeric(12,2) [not null]
  line_total numeric(12,2) [not null]
  added_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (cart_id, variant_id) [unique]
  }
}

Table orders {
  order_id bigserial [pk, increment]
  order_code varchar(30) [not null, unique]
  user_id bigint [not null, ref: > users.user_id]

  cart_id bigint [ref: > carts.cart_id]
  shipping_address_id bigint [ref: > addresses.address_id]
  billing_address_id bigint [ref: > addresses.address_id]

  status order_status [not null, default: 'pending_payment']
  payment_status payment_status [not null, default: 'pending']

  subtotal_amount numeric(12,2) [not null, default: 0]
  discount_amount numeric(12,2) [not null, default: 0]
  shipping_amount numeric(12,2) [not null, default: 0]
  tax_amount numeric(12,2) [not null, default: 0]
  total_amount numeric(12,2) [not null, default: 0]

  note text
  placed_at timestamptz [not null, default: `now()`]
  paid_at timestamptz
  completed_at timestamptz
  cancelled_at timestamptz
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (user_id, created_at)
    (status, created_at)
  }
}

Table order_items {
  order_item_id bigserial [pk, increment]
  order_id bigint [not null, ref: > orders.order_id]
  variant_id bigint [not null, ref: > product_variants.variant_id]

  product_name_snapshot varchar(180) [not null]
  variant_name_snapshot varchar(120) [not null]
  unit_price numeric(12,2) [not null]
  quantity int [not null]
  line_total numeric(12,2) [not null]
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (order_id, variant_id)
  }
}

Table payments {
  payment_id bigserial [pk, increment]
  order_id bigint [not null, ref: > orders.order_id]

  method payment_method [not null]
  status payment_status [not null, default: 'pending']
  amount numeric(12,2) [not null]
  currency varchar(8) [not null, default: 'VND']

  provider varchar(60)
  provider_payment_id varchar(120)
  provider_raw jsonb

  authorized_at timestamptz
  captured_at timestamptz
  failed_at timestamptz
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (order_id)
    (provider, provider_payment_id)
  }
}

Table payment_transactions {
  payment_tx_id bigserial [pk, increment]
  payment_id bigint [not null, ref: > payments.payment_id]
  tx_type varchar(40) [not null]
  amount numeric(12,2) [not null]
  provider_tx_id varchar(120)
  payload jsonb
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (payment_id, created_at)
  }
}

Table shipments {
  shipment_id bigserial [pk, increment]
  order_id bigint [not null, ref: > orders.order_id]
  status shipment_status [not null, default: 'pending']

  carrier varchar(80)
  tracking_number varchar(120)
  shipped_at timestamptz
  delivered_at timestamptz
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (order_id)
    (tracking_number)
  }
}

Table shipment_events {
  shipment_event_id bigserial [pk, increment]
  shipment_id bigint [not null, ref: > shipments.shipment_id]
  event_code varchar(40) [not null]
  event_note text
  event_time timestamptz [not null]
  raw_payload jsonb
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (shipment_id, event_time)
  }
}

Table product_reviews {
  review_id bigserial [pk, increment]
  product_id bigint [not null, ref: > products.product_id]
  user_id bigint [not null, ref: > users.user_id]
  order_item_id bigint [ref: > order_items.order_item_id]
  rating smallint [not null]
  comment text
  is_hidden boolean [not null, default: false]
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (product_id, created_at)
    (user_id, product_id) [unique]
  }
}

Table plants {
  plant_id bigserial [pk, increment]
  scientific_name varchar(180) [not null, unique]
  common_name varchar(180)
  family varchar(120)
  taxonomic_order varchar(120)
  genus varchar(120)
  species varchar(120)
  uses text
  advantages text
  description text
  source varchar(80)
  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (common_name)
    (family)
    (genus)
  }
}

Table plant_aliases {
  alias_id bigserial [pk, increment]
  plant_id bigint [not null, ref: > plants.plant_id]
  alias_name varchar(180) [not null]
  lang_code varchar(8) [not null, default: 'vi']
  is_primary boolean [not null, default: false]

  indexes {
    (plant_id)
    (alias_name, lang_code)
  }
}

Table plant_distribution_areas {
  area_id bigserial [pk, increment]
  plant_id bigint [not null, ref: > plants.plant_id]
  area_name varchar(180) [not null]
  country_code varchar(8)

  indexes {
    (plant_id)
    (area_name)
  }
}

Table plant_distribution_points {
  point_id bigserial [pk, increment]
  plant_id bigint [not null, ref: > plants.plant_id]
  label varchar(180)
  latitude numeric(10,7) [not null]
  longitude numeric(10,7) [not null]

  indexes {
    (plant_id)
    (latitude, longitude)
  }
}

Table scan_requests {
  scan_id bigserial [pk, increment]
  user_id bigint [ref: > users.user_id]

  source scan_source [not null]
  image_url text
  image_sha256 char(64)

  status scan_status [not null]
  confidence numeric(5,4)
  request_payload jsonb
  raw_response jsonb
  error_message text

  model_name varchar(100)
  model_version varchar(60)
  latency_ms int
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (user_id, created_at)
    (status, created_at)
    (image_sha256)
  }
}

Table scan_matches {
  scan_match_id bigserial [pk, increment]
  scan_id bigint [not null, ref: > scan_requests.scan_id]
  plant_id bigint [ref: > plants.plant_id]

  confidence numeric(5,4)
  rank smallint [not null, default: 1]
  source match_source [not null, default: 'ml_model']
  is_selected boolean [not null, default: true]
  created_at timestamptz [not null, default: `now()`]

  indexes {
    (scan_id, rank)
    (plant_id)
  }
}
```

### 3) Mapping app flow -> table
- Auth:
  - Register tao `users` (pending verify) + `OTP`(purpose=`register_verify`).
  - Verify OTP cap nhat `users.email_verified_at`, `OTP.status=verified/consumed`.
  - Login tao `auth_sessions` (hash token), cap nhat `users.last_login_at`.
  - Forgot password dung `OTP` (purpose=`forgot_password`), sau reset cap nhat `users.password_hash`.
- Shop:
  - Home fetch `products`, `product_variants`, `product_images`, `product_categories`.
  - Add to cart update `carts` + `cart_items`, reserve stock trong `inventory_transactions`.
  - Checkout tao `orders` + `order_items` + `payments`; thanh cong thi tru kho (`deduct`) va tao `shipments`.
- Scan:
  - Moi lan upload anh tao `scan_requests`.
  - Ket qua match luu `scan_matches`; neu species moi co the upsert vao `plants` + `plant_distribution_*`.
  - Man hinh ket qua doc tu `scan_requests.raw_response` + thong tin normalized trong `plants`.

### 4) API boundary recommendation
- `Auth API` khong truy cap truc tiep bang shop/scan; chi expose `user_id`, token claims.
- `Shop API` tin vao user identity tu token; khong can biet OTP internals.
- `Scan API` nhan `user_id` tu token (neu co), ghi lich su scan vao `scan_requests`.
- Cross-module communication qua DB relation va event:
  - `order.paid` -> cong `users.score`.
  - `scan.success` -> analytics/recommendation san pham theo plant.

### 5) Phase roadmap (prototype -> production)
- Phase 1 (MVP): `users`, `OTP`, `auth_sessions`, `products`, `product_variants`, `carts`, `cart_items`, `orders`, `order_items`, `payments`, `scan_requests`, `scan_matches`, `plants`.
- Phase 2: inventory full (`variant_inventory`, `inventory_transactions`), shipment tracking, review/rating, user preferences.
- Phase 3: optimize + governance:
  - Partition `scan_requests` theo thang.
  - Read replica cho home/catalog.
  - Data retention cho raw scan payload.
  - Audit log + BI mart cho conversion, scan accuracy, repeat purchase.

## Risk
- OTP security: neu luu otp plaintext se rat nguy hiem -> bat buoc luu hash + TTL + rate-limit resend.
- Token/session drift: neu chi luu token tren client ma khong quan ly `auth_sessions` se kho revoke.
- Ton kho sai: checkout neu khong reserve/release ro rang de gay oversell.
- Payment webhook race condition: phai idempotent theo `provider_payment_id` + `payment_transactions`.
- Scan payload phinh to: `raw_response` co the lon -> can retention policy, co the chuyen object storage cho image.
