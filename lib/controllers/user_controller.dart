import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tretanz_task/app_statics/app_methods.dart';

class UserController extends GetxController{

  Map<String,dynamic> userData = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      _googleSignIn.disconnect();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in the user with Firebase
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      // Add user to Firebase Authentication
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return user;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if(user!=null){
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if(userDoc.data() !=null){
          userData = userDoc.data()!;
          print("user ata");
          AppMethods().printWrapped(userData.toString());
        }
      }
    } catch (e) {}
    update();
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
  }
}