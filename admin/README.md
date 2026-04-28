# BinaBroker Admin Dashboard

Vite React admin dashboard for moderating BinaBroker rental listings.

## Features

- Fetch all listings from Supabase
- Filter by all, pending, active, rejected
- Approve listings
- Reject listings
- Ban broker-like landlords by setting profile role to `broker_flag`
- Strict dark-mode UI

## Environment

Use real values locally or in Vercel. Keep placeholders in GitHub.

```bash
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Local run

```bash
npm install
npm run dev
```

## Vercel settings

```text
Root Directory: admin
Framework Preset: Vite
Build Command: npm run build
Output Directory: dist
```
