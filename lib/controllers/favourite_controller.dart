import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController{

  List<Map<String,dynamic>> favouriteList = [];

  getFavoritePlaces() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if(user!=null){
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        print('userDoc');
        print(userDoc);
        final data = userDoc.data();
        favouriteList = List<Map<String, dynamic>>.from(data?['favorites'] ?? []);
      }
    } catch (e) {
      favouriteList = [];
    }
    update();
  }

}