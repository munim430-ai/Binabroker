class Listing {
  final String id;
  final String landlordId;
  final String title;
  final String? description;
  final int rentAmount;
  final int? areaSqft;
  final int? bedrooms;
  final double? locationLat;
  final double? locationLng;
  final List<String> images;
  final String? contactPhone;
  final String status;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.rentAmount,
    required this.areaSqft,
    required this.bedrooms,
    required this.locationLat,
    required this.locationLng,
    required this.images,
    required this.contactPhone,
    required this.status,
    required this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      landlordId: json['landlord_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      rentAmount: json['rent_amount'] as int? ?? 0,
      areaSqft: json['area_sqft'] as int?,
      bedrooms: json['bedrooms'] as int?,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      images: List<String>.from(json['images'] ?? []),
      contactPhone: json['contact_phone'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
