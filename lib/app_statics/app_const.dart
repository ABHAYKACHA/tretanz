import 'package:geolocator/geolocator.dart';

class AppConst{

  static String googleApiKey = "AIzaSyAD8IkztpapHUJugRhuq2oX4pLT1h_ShNA";

  static Position fixedPosition = Position(
    latitude: 70.776663,
    longitude: 22.288030,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 1.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );

  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const String photoBaseUrl = 'https://maps.googleapis.com/maps/api/place/photo';
  static const String autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
}