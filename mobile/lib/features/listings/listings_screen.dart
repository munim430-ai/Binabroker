import 'package:binabroker/app/theme.dart';
import 'package:binabroker/features/listings/listing_provider.dart';
import 'package:binabroker/shared/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(activeListingsProvider);
    final isLoggedIn = supabase.auth.currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BinaBroker'),
        actions: [
          TextButton(
            onPressed: () => isLoggedIn ? context.push('/add') : context.push('/login'),
            child: const Text('List Property'),
          ),
        ],
      ),
      body: listings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No active listings yet'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(activeListingsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (_, index) {
                final item = items[index];
                final image = item.images.isNotEmpty ? item.images.first : null;

                return GestureDetector(
                  onTap: () => context.push('/details', extra: item),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 286,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        image: image == null
                            ? null
                            : DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xDD000000)],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '৳${item.rentAmount}/month',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
