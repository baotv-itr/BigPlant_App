# Plant Detail Schema

## Purpose
- Day la source-of-truth tam thoi cho du lieu plant detail khi app goi API de hien thi thong tin chi tiet cua cay.
- Khi cap nhat UI scan result / plant detail qua Stitch hoac Flutter, uu tien map theo schema nay truoc.

## Confirmed table

```dbml
Table plants {
  _id bigserial [pk, increment]

  // Ten hien thi chinh thuc trong app
  // Vi du: "Abrus precatorius"
  scientific_name varchar(180) [not null, unique]

  // Ten dung de search / matching / import
  // Vi du: "abrus_precatorius"
  scientific_name_search varchar(180) [not null, unique]

  common_name varchar(180)

  family varchar(120)
  taxonomic_order varchar(120)
  genus varchar(120)
  species varchar(120)

  // accepted | synonym | ambiguous | unmatched | unknown
  taxonomic_status varchar(40)

  uses text
  advantages text
  description text

  // Canh bao doc tinh ngan, dung de show truc tiep tren app
  // Vi du: "Highly toxic seeds; not for self-medication."
  toxicity_warning text

  // Ghi chu an toan chi tiet hon
  safety_notes text

  // traditional_use | in_vitro | animal_study | human_trial | review | insufficient_evidence | unknown
  evidence_level varchar(60)

  // Giu nguyen field source
  // Nen dung text vi danh sach source co the dai
  // Thu tu source map theo cac field phia tren tu tren xuong duoi
  // Vi du:
  // "wiki,wiki,wiki,wiki,wiki,utp,pubmed,gbif,utp,pubmed,pubmed"
  source text

  created_at timestamptz [not null, default: `now()`]
  updated_at timestamptz [not null, default: `now()`]

  indexes {
    (common_name)
    (family)
    (genus)
    (scientific_name_search)
    (taxonomic_status)
    (evidence_level)
  }
}
```

## UI mapping notes
- Header uu tien:
  - `scientific_name`
  - `common_name`
  - `family`, `taxonomic_order`, `genus`, `species`
- Body noi dung uu tien:
  - `description`
  - `uses`
  - `advantages`
- Safety / trust surface:
  - `toxicity_warning`
  - `safety_notes`
  - `evidence_level`
  - `taxonomic_status`
  - `source`
- Search / matching khong can show noi bat tren UI nhung can nho de map backend:
  - `scientific_name_search`

## Implementation note
- Khi response API chi tiet plant duoc map vao Flutter model, can uu tien giu dung ten nghia cua schema nay thay vi suy doan them field khac.
- Neu backend tra field alias khac ten DB, can bo sung adapter/parsing layer nhung van quy ve nhung meaning o tren.
