import '../app_statics/app_const.dart';

class PlaceDetail {
  final String name;
  final String address;
  final List<Review> reviews;
  final String photoUrl;
  final double lat;
  final double lng;

  PlaceDetail({
    required this.name,
    required this.address,
    required this.reviews,
    required this.photoUrl,
    required this.lat,
    required this.lng,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    final photoReference = json['photos'] != null && json['photos'].isNotEmpty
        ? json['photos'][0]['photo_reference']
        : null;

    return PlaceDetail(
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? '',
      reviews: (json['reviews'] as List?)
          ?.map((review) => Review.fromJson(review))
          .toList() ??
          [],
      photoUrl: photoReference != null
          ? '${AppConst.photoBaseUrl}?maxwidth=400&photoreference=$photoReference&key=${AppConst.googleApiKey}'
          : '',
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
    );
  }
}

class Review {
  final String authorName;
  final String text;
  final String profilePhotoUrl;

  Review({
    required this.authorName,
    required this.text,
    required this.profilePhotoUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'] ?? 'Anonymous',
      text: json['text'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? '',
    );
  }
}
