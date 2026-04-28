export type ListingStatus = 'pending' | 'active' | 'rejected';
export type ProfileRole = 'tenant' | 'landlord' | 'broker_flag';

export type Listing = {
  id: string;
  landlord_id: string;
  title: string;
  description: string | null;
  rent_amount: number;
  area_sqft: number | null;
  bedrooms: number | null;
  location_lat: number | null;
  location_lng: number | null;
  images: string[];
  contact_phone: string | null;
  status: ListingStatus;
  created_at: string;
};
