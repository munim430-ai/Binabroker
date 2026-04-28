import 'package:binabroker/app/theme.dart';
import 'package:binabroker/features/listings/listing_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailsScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailsScreen({super.key, required this.listing});

  Future<void> contactOwner(BuildContext context) async {
    final phone = listing.contactPhone;

    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner phone number is not available.')),
      );
      return;
    }

    final cleanPhone = phone.replaceAll('+', '').replaceAll(' ', '');
    final message = Uri.encodeComponent('Hi, I am interested in ${listing.title}');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = listing.images.isNotEmpty ? listing.images.first : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: image == null
                  ? Container(color: AppColors.surface)
                  : Image.network(image, fit: BoxFit.cover),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  listing.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '৳${listing.rentAmount}/month',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  listing.description ?? 'No description provided.',
                  style: const TextStyle(color: AppColors.muted, height: 1.6),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetaChip(label: '${listing.bedrooms ?? 0} Beds'),
                    _MetaChip(label: '${listing.areaSqft ?? 0} sqft'),
                  ],
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton(
          onPressed: () => contactOwner(context),
          child: const Text('Contact Owner'),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label),
    );
  }
}
