import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tretanz_task/models/place_details.dart';
import 'package:tretanz_task/models/place_model.dart';

import '../app_statics/app_methods.dart';
import 'api_controllers.dart';

class SearchAddressController extends GetxController{

  TextEditingController searchString = TextEditingController();
  List<PlaceModel> placeList = [];
  Map<String,dynamic> distance = {
    'distance' : '-',
    'duration' : '-'
  };
  AppMethods appMethods = AppMethods();

  PlaceDetail? placeDetail;

  @override
  void onInit() {
    super.onInit();
    appMethods.determinePosition(); // Determine the user's current location when the controller is initialized
  }

  // Search for places based on user's current location and search query
  searchForValue() async {
    Position currentLocation = await appMethods.determinePosition();
    placeList = await ApiControllers().getNearbyPlaces(
        latitude : currentLocation.latitude,
        longitude: currentLocation.longitude, searchQuery: searchString.text);
    update();
  }

  // Get current position of the user for searching places
  getCurrentPositionForSearch() async {
    return await appMethods.determinePosition(); // Return the current position
  }

  // Fetch details of a place using its placeId and calculate distance from the current location
  getPlaceDetails(String placeId) async {
    final placeDetailResponse = await ApiControllers().getPlaceDetails(placeId);
    if (placeDetailResponse.isNotEmpty) {
      placeDetail = PlaceDetail.fromJson(placeDetailResponse);
      Position currentLocation = await appMethods.determinePosition();
      if(placeDetail!=null && placeDetail?.lat!=null && placeDetail?.lng !=null){
        distance = await ApiControllers().getEstimatedTimeAndDistance(placeDetail!.lat,placeDetail!.lng,currentLocation.latitude,currentLocation.longitude);
      }
      update();  // Update the UI with new data
    }
  }

  // Clear the stored place details
  clearPlace(){
    placeDetail = null;
    update();
  }

  // Add a place to the user's favorites in Firestore
  Future<bool> addFavoritePlace(PlaceModel place) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if(user!=null){
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.update({
            'favorites': FieldValue.arrayUnion([place.toMap()]),
        });
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Remove a place from the user's favorites in Firestore
  Future<bool> removeFavoritePlace(PlaceModel place) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (docSnapshot.exists) {
          final favorites = List<Map<String, dynamic>>.from(docSnapshot.data()?['favorites'] ?? []);

          // Find and remove the matching favorite place
          favorites.removeWhere((favorite) => favorite['placeId'] == place.placeId);

          // Update the document with the new array
          await userDoc.update({'favorites': favorites});
          return true;
        }
      }
      return false;  // Return false if user is not logged in or the document doesn't exist
    } catch (e) {
      print("Error removing favorite place: $e");
      return false;
    }
  }

  // Check if a place is already in the user's favorites
  Future<bool> isPlaceFavorite(String placeId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if(docSnapshot.data() is Map){
        Map<String,dynamic>? favouriteData = docSnapshot.data();
        List? favouriteList = favouriteData?['favorites'];
        if(favouriteList != null){
          return favouriteList.any((favourite) => favourite['placeId'] == placeId);
        }
      }
      return false; // Return false if placeId is not found in the favorites list
    } catch (e) {
      print("Error checking favourite: $e");
      return false; // Return false if an error occurs
    }
  }



}