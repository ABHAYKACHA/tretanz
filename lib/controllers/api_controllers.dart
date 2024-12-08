import 'package:dio/dio.dart';
import 'package:tretanz_task/app_statics/app_methods.dart';
import 'package:tretanz_task/models/place_model.dart';

import '../app_statics/app_const.dart';

class ApiControllers {
  final Dio _dio = Dio();

  // Fetches nearby places based on a search query, latitude, longitude, and optional radius.
  Future<List<PlaceModel>> getNearbyPlaces({
    required String searchQuery,
    required double latitude,
    required double longitude,
    int radius = 1500,
  }) async {
    try {
      // Make the API request
      final response = await _dio.get(AppConst.baseUrl, queryParameters: {
        'key': AppConst.googleApiKey, // Replace with your API key
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'keyword': searchQuery, // Search keyword or place type
      });

      // Extract and format results
      if (response.data?['results'] is List && response.data?['results'].isNotEmpty) {
        return response.data['results'].map<PlaceModel>((place) {
          print("place : ${place}");
          
          return PlaceModel.fromMap({
            'placeId': place['place_id'],
            'name': place['name'],
            'rating': place['rating'],
            'photoUrl': _getPhotoUrl(place),
          });
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching nearby places: $e");
      return [];
    }
  }

  // Helper function to get the photo URL
  String _getPhotoUrl(Map<String, dynamic> place) {
    if (place['photos'] != null && place['photos'].isNotEmpty) {
      final photoReference = place['photos'][0]['photo_reference'];
      return '${AppConst.photoBaseUrl}?maxwidth=400&photoreference=$photoReference&key=${AppConst.googleApiKey}';
    }
    return ''; // Return empty if no photo is available
  }

  // Fetches place suggestions based on user input and location, useful for autocomplete.
  Future<List<Map<String, dynamic>>> getPlaceSuggestions({
    required String input,
    String sessionToken = '',
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Make the API request to fetch place suggestions.
      final response = await _dio.get(AppConst.autocompleteUrl, queryParameters: {
        'key': AppConst.googleApiKey,
        'location': '$latitude,$longitude',
        'input': input,
        'types': 'establishment', // Optional: Filter by types
        'radius': 1500,
      });

      if (response.data?['predictions'] is List) {
        return response.data['predictions'].map<Map<String, dynamic>>((place) {
          return {
            'placeId': place['place_id'],
            'description': place['description'],
            'photoUrl': _getPhotoUrl(place),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching place suggestions: $e");
      return [];
    }
  }

  // Fetches detailed information about a specific place using its place ID.

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': AppConst.googleApiKey,
          'fields': 'name,formatted_address,reviews,photos,geometry',
        },
      );

      if (response.data?['result'] != null) {
        return response.data['result'];
      }
      return {};
    } catch (e) {
      print("Error fetching place details: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> getEstimatedTimeAndDistance(
      double restaurantLat,
      double restaurantLng,
      double destinationLat,
      double destinationLng) async {
    final url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$restaurantLat,$restaurantLng&destinations=$destinationLat,$destinationLng&key=${AppConst.googleApiKey}';

    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final distance = data['rows'][0]['elements'][0]['distance']['text'];
      final duration = data['rows'][0]['elements'][0]['duration']['text'];
      return {'distance': distance, 'duration': duration};
    } else {
      throw Exception('Failed to get distance and duration');
    }
  }


}