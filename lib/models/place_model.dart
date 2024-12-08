class PlaceModel {
  final String placeId;
  final String name;
  final String? rating;
  final String photoUrl;

  // Constructor
  PlaceModel({
    required this.placeId,
    required this.name,
    this.rating,
    required this.photoUrl,
  });

  // Factory method to create a Place object from a map (used for parsing JSON)
  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      placeId: map['placeId'],
      name: map['name'] ?? '',
      rating: map['rating']?.toString(), // Ensure rating is a double
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  // Method to convert a Place object to a map (useful for sending to API or saving)
  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'name': name,
      'rating': rating,
      'photoUrl': photoUrl,
    };
  }
}
