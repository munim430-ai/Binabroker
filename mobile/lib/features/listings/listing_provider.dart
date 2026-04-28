import 'package:binabroker/features/listings/listing_model.dart';
import 'package:binabroker/shared/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final rows = await supabase
      .from('listings')
      .select()
      .eq('status', 'active')
      .order('created_at', ascending: false);

  return rows.map<Listing>((row) => Listing.fromJson(row)).toList();
});
