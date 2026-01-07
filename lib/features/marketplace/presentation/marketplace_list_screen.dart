import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass.dart';
import '../data/marketplace_repository_mock.dart';

class MarketplaceListScreen extends StatefulWidget {
  const MarketplaceListScreen({super.key});

  @override
  State<MarketplaceListScreen> createState() => _MarketplaceListScreenState();
}

class _MarketplaceListScreenState extends State<MarketplaceListScreen> {
  final _repo = MarketplaceRepositoryMock();
  final _search = TextEditingController();

  String _platform = 'All';
  int _maxPrice = 100;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final items = _repo.list().where((l) {
      if (_platform != 'All' && l.platform != _platform) return false;
      if (l.priceUsd > _maxPrice) return false;
      if (q.isEmpty) return true;
      return l.title.toLowerCase().contains(q) ||
          l.id.toLowerCase().contains(q) ||
          l.seller.toLowerCase().contains(q);
    }).toList();

    return ListView(
      children: [
        AppTextField(
          controller: _search,
          label: 'Search',
          hint: 'Listing, seller, ID',
        ),
        const SizedBox(height: 12),
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Platform'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _platform,
                    items: const ['All', 'PC', 'PS', 'Xbox']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _platform = v ?? _platform),
                  ),
                  const Spacer(),
                  Text('Max \$$_maxPrice'),
                ],
              ),
              Slider(
                value: _maxPrice.toDouble(),
                min: 5,
                max: 100,
                divisions: 19,
                onChanged: (v) => setState(() => _maxPrice = v.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            title: 'No listings',
            message: 'Try widening your filters.',
          )
        else
          ...items.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Glass(
                child: InkWell(
                  onTap: () => context.push('/marketplace/listing/${l.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(
                              '${l.platform} • ${l.rating.toStringAsFixed(1)}★ • Seller ${l.seller} (${l.sellerRating.toStringAsFixed(1)}★)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${l.priceUsd}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
