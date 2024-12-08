import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tretanz_task/app_statics/app_methods.dart';
import 'package:tretanz_task/app_statics/assets_path.dart';
import 'package:tretanz_task/models/place_model.dart';

class PlaceListView extends StatefulWidget {
  PlaceModel placeModel;
  VoidCallback onTap;
  PlaceListView({super.key,required this.placeModel,required this.onTap});

  @override
  State<PlaceListView> createState() => _PlaceListViewState();
}

class _PlaceListViewState extends State<PlaceListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppMethods.displayOnlineImage(imagePath: widget.placeModel.photoUrl,height: 100,width: 100),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.placeModel.name,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star,color: Colors.amber),
                    const SizedBox(width: 5),
                    Expanded(child: Text(widget.placeModel.rating ?? '0.0',style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500))),
                  ],
                ),
              ],
            )),

          ],
        ),
      ),
    );
  }
}
