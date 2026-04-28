import { useEffect, useMemo, useState } from 'react';
import { Ban, CheckCircle2, RefreshCw, Settings, XCircle } from 'lucide-react';
import { isSupabaseConfigured, supabase } from '../lib/supabase';
import type { Listing, ListingStatus } from '../types';

const statusStyles: Record<ListingStatus, string> = {
  pending: 'bg-yellow-500/10 text-yellow-300 border-yellow-500/20',
  active: 'bg-emerald-500/10 text-emerald-300 border-emerald-500/20',
  rejected: 'bg-red-500/10 text-red-300 border-red-500/20',
};

export default function ListingsModeration() {
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(isSupabaseConfigured);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'all' | ListingStatus>('all');

  async function fetchListings() {
    if (!isSupabaseConfigured) return;

    setLoading(true);
    setError(null);

    const { data, error: fetchError } = await supabase
      .from('listings')
      .select('*')
      .order('created_at', { ascending: false });

    if (fetchError) {
      setError(fetchError.message);
      setListings([]);
    } else {
      setListings((data ?? []) as Listing[]);
    }

    setLoading(false);
  }

  useEffect(() => {
    fetchListings();
  }, []);

  const filteredListings = useMemo(() => {
    if (filter === 'all') return listings;
    return listings.filter((listing) => listing.status === filter);
  }, [filter, listings]);

  async function updateStatus(id: string, status: ListingStatus) {
    setActionLoading(id);

    const { error: updateError } = await supabase
      .from('listings')
      .update({ status })
      .eq('id', id);

    if (updateError) setError(updateError.message);
    await fetchListings();
    setActionLoading(null);
  }

  async function banLandlord(listing: Listing) {
    setActionLoading(listing.id);

    const { error: profileError } = await supabase
      .from('profiles')
      .update({ role: 'broker_flag' })
      .eq('id', listing.landlord_id);

    const { error: listingError } = await supabase
      .from('listings')
      .update({ status: 'rejected' })
      .eq('landlord_id', listing.landlord_id);

    if (profileError || listingError) {
      setError(profileError?.message || listingError?.message || 'Ban action failed');
    }

    await fetchListings();
    setActionLoading(null);
  }

  if (!isSupabaseConfigured) {
    return (
      <div className="rounded-2xl border border-border bg-surface p-6">
        <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-ocean/15 text-ocean">
          <Settings size={24} />
        </div>
        <h2 className="mt-5 text-3xl font-black tracking-tight">Supabase setup required</h2>
        <p className="mt-3 max-w-2xl text-mutedText">
          The dashboard deployed successfully. Add real Supabase environment variables in Vercel to enable listing moderation.
        </p>
        <div className="mt-6 rounded-xl border border-border bg-matte p-4 font-mono text-sm text-mutedText">
          <div>VITE_SUPABASE_URL=your_real_supabase_url</div>
          <div className="mt-2">VITE_SUPABASE_ANON_KEY=your_real_supabase_anon_key</div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col justify-between gap-4 md:flex-row md:items-end">
        <div>
          <h2 className="text-3xl font-black tracking-tight">Listings Moderation</h2>
          <p className="mt-2 max-w-2xl text-mutedText">
            Review rental submissions, approve valid owner listings, reject bad listings, and flag broker-like accounts.
          </p>
        </div>

        <button
          onClick={fetchListings}
          className="inline-flex items-center justify-center gap-2 rounded-xl border border-border bg-surface px-4 py-3 text-sm font-bold text-primaryText transition hover:border-ocean hover:text-ocean"
        >
          <RefreshCw size={16} /> Refresh
        </button>
      </div>

      <div className="grid gap-3 sm:grid-cols-4">
        {(['all', 'pending', 'active', 'rejected'] as const).map((item) => (
          <button
            key={item}
            onClick={() => setFilter(item)}
            className={`rounded-xl border px-4 py-3 text-left font-bold capitalize transition ${
              filter === item
                ? 'border-ocean bg-ocean text-white'
                : 'border-border bg-surface text-mutedText hover:text-primaryText'
            }`}
          >
            {item}
          </button>
        ))}
      </div>

      {error && (
        <div className="rounded-xl border border-red-500/20 bg-red-500/10 px-4 py-3 text-sm text-red-300">
          {error}
        </div>
      )}

      <div className="overflow-hidden rounded-2xl border border-border bg-surface">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[980px] border-collapse text-left text-sm">
            <thead className="border-b border-border bg-matte/70 text-mutedText">
              <tr>
                <th className="px-5 py-4 font-bold">Listing</th>
                <th className="px-5 py-4 font-bold">Rent</th>
                <th className="px-5 py-4 font-bold">Specs</th>
                <th className="px-5 py-4 font-bold">Contact</th>
                <th className="px-5 py-4 font-bold">Status</th>
                <th className="px-5 py-4 font-bold">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-5 py-10 text-center text-mutedText">Loading listings...</td>
                </tr>
              ) : filteredListings.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-5 py-10 text-center text-mutedText">No listings found.</td>
                </tr>
              ) : (
                filteredListings.map((listing) => (
                  <tr key={listing.id} className="border-b border-border/70 last:border-0">
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-4">
                        <div className="h-16 w-20 overflow-hidden rounded-xl bg-matte">
                          {listing.images?.[0] ? (
                            <img src={listing.images[0]} alt="" className="h-full w-full object-cover" />
                          ) : null}
                        </div>
                        <div>
                          <div className="max-w-[260px] truncate font-extrabold">{listing.title}</div>
                          <div className="mt-1 max-w-[300px] truncate text-mutedText">{listing.description || 'No description'}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-5 py-4 font-extrabold text-ocean">৳{listing.rent_amount}</td>
                    <td className="px-5 py-4 text-mutedText">
                      {listing.bedrooms ?? 0} beds · {listing.area_sqft ?? 0} sqft
                    </td>
                    <td className="px-5 py-4 text-mutedText">{listing.contact_phone || 'N/A'}</td>
                    <td className="px-5 py-4">
                      <span className={`rounded-full border px-3 py-1 text-xs font-black capitalize ${statusStyles[listing.status]}`}>
                        {listing.status}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <div className="flex flex-wrap gap-2">
                        <button
                          disabled={actionLoading === listing.id}
                          onClick={() => updateStatus(listing.id, 'active')}
                          className="inline-flex items-center gap-1 rounded-lg bg-emerald-500/10 px-3 py-2 text-xs font-bold text-emerald-300 hover:bg-emerald-500/20 disabled:opacity-50"
                        >
                          <CheckCircle2 size={14} /> Approve
                        </button>
                        <button
                          disabled={actionLoading === listing.id}
                          onClick={() => updateStatus(listing.id, 'rejected')}
                          className="inline-flex items-center gap-1 rounded-lg bg-red-500/10 px-3 py-2 text-xs font-bold text-red-300 hover:bg-red-500/20 disabled:opacity-50"
                        >
                          <XCircle size={14} /> Reject
                        </button>
                        <button
                          disabled={actionLoading === listing.id}
                          onClick={() => banLandlord(listing)}
                          className="inline-flex items-center gap-1 rounded-lg bg-orange-500/10 px-3 py-2 text-xs font-bold text-orange-300 hover:bg-orange-500/20 disabled:opacity-50"
                        >
                          <Ban size={14} /> Ban
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
