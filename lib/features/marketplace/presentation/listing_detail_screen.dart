import 'package:flutter/material.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/marketplace_repository_mock.dart';
import '../domain/models.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context) {
    final repo = MarketplaceRepositoryMock();
    final listing = repo.list().firstWhere(
          (l) => l.id == listingId,
          orElse: () => Listing(
            id: listingId,
            title: 'Unknown Listing',
            platform: 'N/A',
            rating: 0,
            priceUsd: 0,
            seller: 'N/A',
            sellerRating: 0,
          ),
        );

    return GlassScaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  '${listing.platform} • ${listing.rating.toStringAsFixed(1)}★ • \$${listing.priceUsd}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seller: ${listing.seller} (${listing.sellerRating.toStringAsFixed(1)}★)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actions',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Secure chat (placeholder).')),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Secure Chat'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Escrow start (placeholder).')),
                      );
                    },
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Start Escrow'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TODO(backend): Implement chat + escrow flow.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
