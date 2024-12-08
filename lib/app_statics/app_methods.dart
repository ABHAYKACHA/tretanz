import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

import 'app_const.dart';
import 'assets_path.dart';

class AppMethods {
  Position? _cachedPosition; // To store the position once it's determined

  Future<Position> determinePosition() async {

    // If the position is already cached, return it immediately
    if (_cachedPosition != null) {
      return _cachedPosition!;
    }

    LocationPermission permission;

    // Check and request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _cachedPosition = AppConst.fixedPosition; // Fallback to fixed position
        return _cachedPosition!;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _cachedPosition = AppConst.fixedPosition; // Fallback to fixed position
      return _cachedPosition!;
    }

    // Fetch and cache the current position
    _cachedPosition = await Geolocator.getCurrentPosition();
    print("doneennene");
    return _cachedPosition!;
  }


  static displayOnlineImage(
      {required String imagePath,
        BoxFit fit = BoxFit.fill,
        double? height = null,
        double? width = null}) {
    return Image.network(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            height: height,
            width: width,
            child: Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          ),
        );
      },
      errorBuilder: (ctx, err, _) {
        return Image.asset(AssetsPath.placeholder,height: height,width: width,);
      },
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static showLoading(
      {EasyLoadingIndicatorType loadingType = EasyLoadingIndicatorType.ring,
        Color? backgroundColor,
        String message = ''}) {
    EasyLoading.instance
      ..indicatorType = loadingType
      ..loadingStyle = EasyLoadingStyle.custom
      ..radius = 5
      ..indicatorColor = Colors.white
      ..backgroundColor = Colors.transparent
      ..textColor = Colors.white
      ..userInteractions = true
      ..dismissOnTap = false;
    EasyLoading.show(status: message);
  }

  //Close loading
  static closeLoading() {
    EasyLoading.dismiss();
  }

  static showSnackBar({
    required BuildContext context,
    required String message}){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
