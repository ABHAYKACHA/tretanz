import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tretanz_task/views/favourite_view.dart';
import 'package:tretanz_task/views/profile_views.dart';
import 'package:tretanz_task/views/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  ValueNotifier bottomNavigationBar = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tretanz Infotech"),
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: bottomNavigationBar,
            builder: (context, value, child) {
              if(bottomNavigationBar.value == 0){
                return Expanded(child: SearchScreen());
              }else if(bottomNavigationBar.value == 1){
                return const Expanded(child: FavouriteScreen());
              }else if(bottomNavigationBar.value == 2){
                return const Expanded(child: ProfileView());
              }else{
                return Expanded(child: SearchScreen());
              }
          },)
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: bottomNavigationBar,
        builder: (context, value, child) {
          return BottomNavigationBar(
            currentIndex: bottomNavigationBar.value,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_outlined),
                label: 'favourite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_sharp),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                bottomNavigationBar.value = 0;
              } else if (index == 1) {
                bottomNavigationBar.value = 1;
              } else if (index == 2) {
                bottomNavigationBar.value = 2;
              }
            },
          );
        }
      ),

    );
  }
}
