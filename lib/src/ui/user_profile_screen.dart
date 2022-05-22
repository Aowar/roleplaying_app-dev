import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';
import 'package:roleplaying_app/src/services/file_upload_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/fetch_info.dart';

late String _userId;

class UserProfileScreen extends StatefulWidget{
  String userId;

  UserProfileScreen({Key? key, required this.userId}) : super(key: key) {
    _userId = userId;
  }

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isOpen = false;
  late OverlayEntry _overlayEntry;

  Stream<List<CustomUserModel>> _readUser(String userId) => FirebaseFirestore.instance.collection("users").where("userId", isEqualTo:  _userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => CustomUserModel.fromJson(doc.data())).toList()
  );

  void openContextMenu() {
    isOpen = true;
    _overlayEntry = _createRegisterOverlay();
    Overlay.of(context)!.insert(_overlayEntry);
  }

  void closeContextMenu() {
    isOpen = false;
    _overlayEntry.remove();
  }

  OverlayEntry _createRegisterOverlay() {
    return OverlayEntry(builder: (context) {
      return GestureDetector(
        onTap: closeContextMenu,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    spreadRadius: 5,
                    offset: const Offset(5, 5),
                    blurRadius: 10
                )
              ]
          ),
        )
      );
    });
  }

  ///Getting user
  userNickName(String userId) {
    return StreamBuilder<List<CustomUserModel>>(
      stream: _readUser(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      itemCount: user.length,
                      itemBuilder: (BuildContext context, int index) {
                         return Text(user[index].nickName.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline2
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                    ),
                  )
                ],
              )
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState> (
         builder: (context, state) {
           if (state is AuthStateAuthenticated) {
             return Scaffold(
               body: Stack(
                 children: [
                   const Positioned(
                       left: 15,
                       top: 15,
                       child: utils.BackButton()
                   ),
                   Center(
                     child: Padding(
                         padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                         child: Column(
                           children: [
                             ElevatedButton(
                               style: ButtonStyle(
                                 backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                                 shape: MaterialStateProperty.all(const CircleBorder()),
                               ),
                               child: Icon(Icons.account_circle_sharp,
                                 size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*20),
                                 color: Colors.white,
                               ),
                               onPressed: () async
                               {
                                 final ImagePicker _picker = ImagePicker();
                                 XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                 FileUploadService().uploadImage("users_pics", image!.path, image.name);
                               },
                             ),
                             Padding(
                                 padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 40),
                                 child: Center(
                                   child: SizedBox(
                                       height: MediaQuery.of(context).size.height / 10,
                                       width: MediaQuery.of(context).size.width / 2,
                                       child: Container(
                                         child: userNickName(_userId),
                                       )
                                   ),
                                 )
                             ),
                             Padding(
                               padding: const EdgeInsets.only(top: 30),
                               child: Container (
                                 constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.7),
                                 child: SizedBox(
                                   width: MediaQuery.of(context).size.width / 1.1,
                                   child: Container(
                                     decoration: BoxDecoration(
                                         color: Theme.of(context).cardColor,
                                         borderRadius: const BorderRadius.all(
                                           Radius.circular(20.0),
                                         ),
                                         boxShadow: [
                                           BoxShadow(
                                               color: Theme.of(context).cardColor.withOpacity(0.2),
                                               spreadRadius: 2,
                                               offset: const Offset(5, 5),
                                               blurRadius: 10
                                           )
                                         ]
                                     ),
                                     child: Stack(
                                       children: [
                                         Padding(
                                           padding: const EdgeInsets.only(left: 10, top: 2),
                                           child: Text(state.getUser()!.id == _userId ? "Мои анкеты" : "Анкеты пользователя",
                                             style: Theme.of(context).textTheme.headline2,
                                           ),
                                         ),
                                         Padding(
                                             padding: const EdgeInsets.only(left: 20, top: 35),
                                             child: FetchInfoFromDb.itemOfProfilesList(_userId)
                                         ),
                                         state.getUser()!.id == _userId ? Positioned(
                                             right: 5,
                                             top: 5,
                                             child: utils.PushButton(icon: Icons.add, route: MaterialPageRoute(builder: (context) => ProfileEditScreen.create()))
                                         ) : Container()
                                       ],
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                             // Padding(
                             //   padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 40),
                             //   child: SizedBox(
                             //     width: MediaQuery.of(context).size.width / 1.1,
                             //     height: MediaQuery.of(context).size.height / 1.9,
                             //     child: Neumorphic(
                             //       style: NeumorphicStyle(
                             //         shape: NeumorphicShape.flat,
                             //         boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                             //         depth: 2.0,
                             //         color: Theme.of(context).cardColor,
                             //       ),
                             //       child: Stack(
                             //         children: [
                             //           Positioned(
                             //             left: 15,
                             //             top: 10,
                             //             child: Text("Комментарии:",
                             //               style: Theme.of(context).textTheme.headline2,
                             //             ),
                             //           ),
                             //           Center(
                             //             child: Padding(
                             //                 padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
                             //                 child: Column(
                             //                   children: [
                             //                     Utils.GenerateMessageContainer('/profile_screen', Icons.account_circle_sharp, context, 'Пользователь 2'),
                             //                     Center(
                             //                       child: Padding(
                             //                           padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5, left: MediaQuery.of(context).size.width / 90),
                             //                           child: Row(
                             //                             children: [
                             //                               SizedBox(
                             //                                   width: MediaQuery.of(context).size.width / 1.35,
                             //                                   height: MediaQuery.of(context).size.height / 22.8,
                             //                                   child: SizedBox(
                             //                                     width: MediaQuery.of(context).size.width / 1.5,
                             //                                     height: MediaQuery.of(context).size.height / 50,
                             //                                     child: Neumorphic(
                             //                                         style: NeumorphicStyle(
                             //                                             shape: NeumorphicShape.convex,
                             //                                             boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                             //                                             depth: 5.0,
                             //                                             color: Theme.of(context).accentColor
                             //                                         ),
                             //                                         child: Padding(
                             //                                           padding: EdgeInsets.only(left: 10),
                             //                                           child: TextField(
                             //                                               decoration: InputDecoration(
                             //                                                   border: InputBorder.none,
                             //                                                   hintText: "Комментарий",
                             //                                                   hintStyle: TextStyle(
                             //                                                       color: Theme.of(context).textTheme.bodyText2?.color
                             //                                                   )
                             //                                               )
                             //                                           ),
                             //                                         )
                             //                                     ),
                             //                                   )
                             //                               ),
                             //                               Padding(
                             //                                 padding: EdgeInsets.only(left: 5),
                             //                                 child: Utils.GenerateButton('', Icons.arrow_forward_ios_rounded, context),
                             //                               )
                             //                             ],
                             //                           )
                             //                       ),
                             //                     )
                             //                   ],
                             //                 )
                             //             ),
                             //           )
                             //         ],
                             //       ),
                             //     ),
                             //   ),
                             // )
                           ],
                         )
                     ),
                   ),
                 ],
               ),
             );
           }
           return AuthScreen();
         });
  }
}