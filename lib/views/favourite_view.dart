import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tretanz_task/controllers/favourite_controller.dart';
import 'package:tretanz_task/controllers/search_controller.dart';
import 'package:tretanz_task/custom_widgets/place_list_view.dart';
import 'package:tretanz_task/models/place_model.dart';
import 'package:tretanz_task/views/place_detail.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {

  FavouriteController favouriteController = Get.put(FavouriteController());
  ValueNotifier loading = ValueNotifier(true);
  SearchAddressController searchController = Get.put(SearchAddressController());


  @override
  void initState() {
    super.initState();
    favouriteController.getFavoritePlaces().whenComplete(()=>loading.value = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: loading,
        builder: (context, value, child) {
          if(loading.value == true){
            return const Center(child: CircularProgressIndicator());
          }else{
            return GetBuilder<FavouriteController>(
              builder: (controller) {
                return
                  favouriteController.favouriteList.isNotEmpty ?
                  ListView.builder(
                  itemCount: favouriteController.favouriteList.length,
                  itemBuilder: (context, index) {
                    final place = favouriteController.favouriteList[index];
                    return PlaceListView(
                      placeModel: PlaceModel.fromMap({
                        'placeId': place['placeId'] ?? '',
                        'name': place['name'] ?? '',
                        'rating': place['rating'] ?? '',
                        'photoUrl': place['photoUrl'] ?? '',
                      }),
                      onTap: () async {
                        await Get.to(PlaceDetailScreen(placeId: favouriteController.favouriteList[index]['placeId'], placeModel: PlaceModel.fromMap({
                          'placeId': place['placeId'] ?? '',
                          'name': place['name'] ?? '',
                          'rating': place['rating'] ?? '',
                          'photoUrl': place['photoUrl'] ?? '',
                        })));
                        // searchController.clearPlace();
                      },
                    );
                  },
                ) : const Center(child: Text("No favourite Item found"));
              },
            );
          }
        }
      ),
    );
  }
}
