# Product Catalog Schema

## Purpose
- Day la source-of-truth tam thoi cho du lieu product catalog va product detail trong app.
- Khi build `Home Tab`, `Product Detail`, cart, variant picker hoac map product -> plant, uu tien map theo schema nay truoc.

## Confirmed tables

```dbml
Table products {
  _id string [pk, increment]
  category_id bigint [ref: > product_categories._id]
  plant_id bigint [not null, ref: > plants._id]
  sku varchar(64) [not null, unique]
  product_type product_type [not null, default: 'plant']

  name varchar(180) [not null]
  slug varchar(220) [not null, unique]

  short_description varchar(255)
  description text
  care_level varchar(32)

  rating_avg numeric(3,2) [not null, default: 0, check: `rating_avg >= 0 AND rating_avg <= 5`]
  rating_count int [not null, default: 0, check: `rating_count >= 0`]

  is_active boolean [not null, default: true]

  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (category_id, is_active)
    (name)
  }
}

Table product_categories {
  _id bigserial [pk, increment]

  name varchar(120) [not null]
  slug varchar(160) [not null, unique]
  description text

  is_active boolean [not null, default: true]
  sort_order int [not null, default: 0]

  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]
}

Table product_variants {
  _id bigserial [pk, increment]
  product_id bigint [not null, ref: > products._id]

  variant_sku varchar(64) [not null, unique]
  variant_name varchar(120) [not null]

  attributes jsonb

  price numeric(12,2) [not null, check: `price >= 0`]
  compare_at_price numeric(12,2) [check: `compare_at_price IS NULL OR compare_at_price >= 0`]
  weight_gram int [check: `weight_gram IS NULL OR weight_gram >= 0`]

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
  image_id string [pk, increment]
  product_id bigint [ref: > products._id]
  variant_id bigint [ref: > product_variants._id]

  image_url text [not null]
  alt_text varchar(255)

  sort_order int [not null, default: 0]
  is_primary boolean [not null, default: false]

  created_at timestamptz [not null, default: `now()`]
}
```

## Business logic note
- Neu `products.category_id` tro toi `product_categories.name = "plant"` thi `products.plant_id` phai ton tai va mo ta thong tin cua 1 cay lien ket.
- Nghia la `Product Detail` cua plant product can co 2 lop thong tin:
  - Product layer: ten san pham, slug, mo ta ngan, mo ta chi tiet, care level, rating, variant, image.
  - Plant layer: thong tin botanical / plant detail duoc lien ket qua `plant_id`.

## UI mapping notes
- `Home Tab` uu tien card/list theo `products` + image primary + variant default + rating.
- `Product Detail` uu tien:
  - `products.name`
  - image primary / gallery tu `product_images`
  - gia tu default variant trong `product_variants`
  - `short_description`
  - `description`
  - `care_level`
  - `rating_avg`, `rating_count`
  - variant selector
- Neu product la plant thi co the show them thong tin plant lien ket, nhung boundary product va boundary plant can tach ro trong view-model.

## Implementation note
- Trong Flutter, nen tach model:
  - product category
  - product summary/detail
  - variant
  - image
  - linked plant snapshot/detail
- Neu chua co API shop thuc te, local mock data van phai ton trong hinh dang tuong thich voi schema tren de giam cong adapter ve sau.
