# BinaBroker

Zero-brokerage real estate rental ecosystem for Bangladesh.

## Phase 1: Flutter Mobile App

This repo currently contains the Phase 1 Flutter app scaffold under `mobile/`.

### Features

- Supabase phone OTP auth for Bangladesh `+880` numbers
- Riverpod-powered active listings feed
- Premium matte black UI using Inter typography
- Listing details screen with WhatsApp owner contact
- Add listing flow with image upload to Supabase Storage
- Supabase-backed listings, profiles, and storage integration

### Run locally

```bash
cd mobile
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Supabase requirement for Phase 1 contact flow

The Flutter app stores owner contact phone directly on each listing so users can contact the owner from the details page.

Run this in Supabase SQL Editor if your previous schema does not already include it:

```sql
alter table public.listings
add column if not exists contact_phone text;
```
