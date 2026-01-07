class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.platform,
    required this.rating,
    required this.priceUsd,
    required this.seller,
    required this.sellerRating,
  });

  final String id;
  final String title;
  final String platform; // PC / PS / Xbox
  final double rating; // 0..5
  final int priceUsd;
  final String seller;
  final double sellerRating;
}
