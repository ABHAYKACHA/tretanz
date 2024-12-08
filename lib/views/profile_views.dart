import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tretanz_task/app_statics/app_methods.dart';
import 'package:tretanz_task/controllers/user_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  ValueNotifier loading = ValueNotifier(true);
  UserController userController = Get.put(UserController());

  @override
  void initState() {
    userController.getUserData().whenComplete(()=> loading.value = false);
    super.initState();
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
              return GetBuilder<UserController>(
                builder: (controller) {
                  return SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: AppMethods.displayOnlineImage(imagePath: userController.userData['photoURL'] ?? '',height: 180,width: 180),
                        ),


                        const SizedBox(height: 20,),
                        Text(userController.userData['name'] ?? '',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              AppMethods.showLoading();
                              await userController.logout().whenComplete(()=>AppMethods.closeLoading());
                            },
                            child: Card(
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.logout),
                                      SizedBox(width: 10),
                                      Text("Logout"),
                                    ],
                                  ),
                                ),
                              ),
                          ),
                        ),

                      ],
                    ),
                  );
                },
              );
            }
          }
      ),
    );
  }
}
