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
    appMethods.determinePosition();
  }

  searchForValue() async {
    Position currentLocation = await appMethods.determinePosition();
    placeList = await ApiControllers().getNearbyPlaces(
        latitude : currentLocation.latitude,
        longitude: currentLocation.longitude, searchQuery: searchString.text);
    update();
  }

  getCurrentPositionForSearch() async {
    return await appMethods.determinePosition();
  }

  getPlaceDetails(String placeId) async {
    final placeDetailResponse = await ApiControllers().getPlaceDetails(placeId);
    if (placeDetailResponse.isNotEmpty) {
      placeDetail = PlaceDetail.fromJson(placeDetailResponse);
      Position currentLocation = await appMethods.determinePosition();
      if(placeDetail!=null && placeDetail?.lat!=null && placeDetail?.lng !=null){
        distance = await ApiControllers().getEstimatedTimeAndDistance(placeDetail!.lat,placeDetail!.lng,currentLocation.latitude,currentLocation.longitude);
        print("distance");
        print(distance);
      }
      update();
    }
  }

  clearPlace(){
    placeDetail = null;
    update();
  }

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
      return false;
    } catch (e) {
      print("Error removing favorite place: $e");
      return false;
    }
  }
  Future<bool> isPlaceFavorite(String placeId) async {
    try {
      print('placeId');
      print(placeId);
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
      return false;
    } catch (e) {
      print("Error checking favourite: $e");
      return false;
    }
  }



}