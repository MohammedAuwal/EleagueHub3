import '../domain/models.dart';

class MarketplaceRepositoryMock {
  // TODO(backend): integrate listing feed, chat, escrow, payments
  List<Listing> list() {
    return [
      Listing(
        id: 'P-100',
        title: 'Elite WL Coaching Session (1h)',
        platform: 'PC',
        rating: 4.8,
        priceUsd: 25,
        seller: 'CoachNova',
        sellerRating: 4.9,
      ),
      Listing(
        id: 'P-203',
        title: 'Custom Tactics Pack + Review',
        platform: 'PS',
        rating: 4.6,
        priceUsd: 15,
        seller: 'TacticianApex',
        sellerRating: 4.7,
      ),
      Listing(
        id: 'P-311',
        title: 'Rank Push Duo Queue',
        platform: 'Xbox',
        rating: 4.4,
        priceUsd: 18,
        seller: 'VortexCarry',
        sellerRating: 4.5,
      ),
    ];
  }
}
