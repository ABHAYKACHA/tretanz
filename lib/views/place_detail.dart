import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_statics/app_methods.dart';
import '../controllers/search_controller.dart';
import '../models/place_model.dart';

class PlaceDetailScreen extends StatefulWidget {
  String placeId;
  PlaceModel placeModel;

  PlaceDetailScreen({required this.placeId, required this.placeModel});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {

  SearchAddressController searchController = Get.put(SearchAddressController());
  ValueNotifier favourite = ValueNotifier(false);
  ValueNotifier loading = ValueNotifier(true);

  @override
  void initState() {
    fetchData().whenComplete((){
      loading.value = false;
    });
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
    searchController.clearPlace();
  }

  fetchData() async {
    await searchController.getPlaceDetails(widget.placeId);
    await searchController.isPlaceFavorite(widget.placeId).then((value) {
      if(value == true){
        favourite.value = true;
      }else{
        favourite.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.placeModel.name),
        actions: [],
      ),
      body: ValueListenableBuilder(
        valueListenable: loading,
        builder:(context, value, child)  {
          if(loading.value == true){
            return const Center(child: CircularProgressIndicator());
          }else{
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: GetBuilder<SearchAddressController>(
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Place Image

                        AppMethods.displayOnlineImage(imagePath: searchController.placeDetail?.photoUrl ?? '',height: 250,width: double.maxFinite,fit: BoxFit.cover),
                        const SizedBox(height: 16),

                        // Place Name and Address
                        Text(searchController.placeDetail?.name ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(searchController.placeDetail?.address ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Text("Distance : ${searchController.distance['distance']}"),
                                    Text("Duration : ${searchController.distance['duration']}")
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                final url =
                                    'https://www.google.com/maps/dir/?api=1&destination=${searchController.placeDetail?.lat},${searchController.placeDetail?.lng}';
                                launchUrl(Uri.parse(url));

                              },
                              icon: Icon(Icons.directions),
                              label: Text("Get Directions"),
                            ),
                          ],
                        ),

                        ValueListenableBuilder(
                            valueListenable: favourite,
                            builder: (context, value, child){
                              return Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                      style: ButtonStyle(
                                        backgroundColor: favourite.value == true ? MaterialStateProperty.all(Colors.blueAccent) : null,
                                      ),
                                      onPressed: () async {
                                        if(favourite.value == true){
                                          bool favouriteRes = await searchController.removeFavoritePlace(widget.placeModel);
                                          String favouriteMessage = '';
                                          if(favouriteRes == true){
                                            favourite.value = false;
                                            favouriteMessage = "Removed place from favourite";
                                          }else{
                                            favouriteMessage = "Something went wrong in removing a place to favourite please try again later.";
                                          }

                                          AppMethods.showSnackBar(context: context, message:favouriteMessage);
                                        }else{
                                          bool favouriteRes = await searchController.addFavoritePlace(widget.placeModel);
                                          String favouriteMessage = '';
                                          if(favouriteRes == true){
                                            favourite.value = true;
                                            favouriteMessage = "Added place to favourite";
                                          }else{
                                            favouriteMessage = "Something went wrong in adding a place to favourite please try again later.";
                                          }
                                          AppMethods.showSnackBar(context: context, message:favouriteMessage);
                                        }
                                      }, child: const Text("Favourite")));
                            }
                        ),

                        // Reviews
                        if (searchController.placeDetail?.reviews != null && searchController.placeDetail!.reviews.isNotEmpty) ...[
                          const Text("User Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...searchController.placeDetail!.reviews.map((review) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: review.profilePhotoUrl.isNotEmpty
                                    ? NetworkImage(review.profilePhotoUrl)
                                    : null,
                                backgroundColor: Colors.grey[200],
                                child: review.profilePhotoUrl.isEmpty
                                    ? const Icon(Icons.person, color: Colors.grey)
                                    : null,
                              ),
                              title: Text(review.authorName, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: ExpandableText(
                                review.text, expandText: 'show more',
                                collapseText: 'show less',
                                maxLines: 3,
                                linkColor: Colors.blueAccent,

                              ),
                            );
                          }).toList(),
                        ],

                        // "Get Directions" Button
                        SizedBox(height: 16),
                      ],
                    );
                  }
              ),
            );
          }
        }
      ),
    );
  }
}
