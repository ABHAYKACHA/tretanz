import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tretanz_task/controllers/api_controllers.dart';
import 'package:tretanz_task/custom_widgets/place_list_view.dart';
import 'package:tretanz_task/views/place_detail.dart';

import '../app_statics/app_methods.dart';
import '../app_statics/debounce.dart';
import '../controllers/search_controller.dart';
import '../models/place_details.dart';
import '../models/place_model.dart';


class SearchScreen extends StatelessWidget {

  TextEditingController controller = TextEditingController();
  final Debounce _debounce = Debounce();

  SearchAddressController searchController = Get.put(SearchAddressController());



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Row(
              children: [
                Flexible(
                  child: Autocomplete<Map<String,dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      print("caleldd");
                      searchController.searchString.text = textEditingValue.text.trim();
                      if (textEditingValue.text.trim().isEmpty) {
                      return {};
                    }
                    Completer<List<Map<String,dynamic>>> completer = Completer();
                    _debounce(() async {
                      Position currentLocation = await searchController.getCurrentPositionForSearch();
                      List<Map<String,dynamic>> list = await ApiControllers().getPlaceSuggestions(
                        input: textEditingValue.text,
                        latitude: currentLocation.latitude,
                        longitude: currentLocation.longitude,
                      );
                      completer.complete(list);
                    });
                    return completer.future;
                  },
                    onSelected: (value) async {

                      if(value.containsKey('placeId')){
                        await Get.to(PlaceDetailScreen(placeId: value['placeId'], placeModel: PlaceModel.fromMap({
                          'placeId': value['placeId'] ?? '',
                        })));
                        // searchController.clearPlace();
                        // _autocompleteKey.
                      }
                  },fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onSubmitted: (String value) => onFieldSubmitted(),
                      decoration: const InputDecoration(
                        hintText: 'Search places...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                    );
                  },optionsMaxHeight: double.maxFinite,
                    optionsViewBuilder: (
                        BuildContext context,
                        Function(Map<String, dynamic>) onSelected,
                        Iterable<Map<String, dynamic>> options,
                        ) {
                      return Material(
                        elevation: 4.0,
                        child: SizedBox(
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(options.length, (index) {
                                final Map<String, dynamic> option = options.elementAt(index); // Get the map.
                                final String description = option['description'] ?? 'Unknown'; // Extract description for display.
                                return InkWell(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      description,
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      );
                    },),
                ),
                IconButton(onPressed: () async {
                  FocusScope.of(context).unfocus();
                  AppMethods.showLoading();
                  await searchController.searchForValue().whenComplete(()=>AppMethods.closeLoading());
                }, icon: const Icon(Icons.search))
              ],
            ),


            Expanded(
              child: GetBuilder<SearchAddressController>(
                builder: (context) {
                  return ListView.builder(
                    itemCount: searchController.placeList.length,
                    itemBuilder: (context, index) {
                      return PlaceListView(
                          placeModel: searchController.placeList[index],
                        onTap: () async {
                            await Get.to(PlaceDetailScreen(placeId: searchController.placeList[index].placeId, placeModel: searchController.placeList[index]));
                            // searchController.clearPlace();
                        },
                      );
                  },);
                }
              ),
            )

            // ElevatedButton(onPressed: () async {
            //   Position currentLocation = await AppMethods().determinePosition();
            //   List list = await ApiControllers().getPlaceSuggestions(input: 'school',
            //       latitude : currentLocation.latitude,
            //       longitude: currentLocation.longitude);
            //   print(list);
            //
            // }, child: const Text("Click me first")),



            // ElevatedButton(onPressed: () async {
            //   Position currentLocation = await AppMethods().determinePosition();
            //    List<Map<String,dynamic>> places = await ApiControllers().getNearbyPlaces(
            //        latitude : currentLocation.latitude,longitude: currentLocation.longitude,
            //      searchQuery: 'school',
            //    );
            //    if(places.isNotEmpty){
            //      places.forEach((element) {
            //        print(element);
            //      });
            //    }
            // }, child: Text("Click me")),
          ],
        ),
      ),
    );
  }
}
