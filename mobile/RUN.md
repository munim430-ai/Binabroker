# Run BinaBroker Mobile

## 1. Install dependencies

```bash
cd mobile
flutter pub get
```

## 2. Run with Supabase environment values

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 3. Required Supabase migration

Run this in Supabase SQL Editor, or apply the migration in `supabase/migrations/20260428_add_contact_phone_to_listings.sql`.

```sql
alter table public.listings
add column if not exists contact_phone text;
```

## 4. Required Supabase Storage bucket

Create a public bucket named:

```text
listing-images
```

The Phase 1 app uploads listing photos to this bucket.
