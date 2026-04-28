import { createClient } from '@supabase/supabase-js';

const rawSupabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const rawSupabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const isSupabaseConfigured =
  Boolean(rawSupabaseUrl) &&
  Boolean(rawSupabaseAnonKey) &&
  rawSupabaseUrl !== 'your_supabase_url' &&
  rawSupabaseAnonKey !== 'your_supabase_anon_key';

const supabaseUrl = isSupabaseConfigured
  ? rawSupabaseUrl
  : 'https://placeholder.supabase.co';

const supabaseAnonKey = isSupabaseConfigured
  ? rawSupabaseAnonKey
  : 'placeholder-anon-key';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
