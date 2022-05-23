import 'dart:developer' as dev;
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';
import 'package:roleplaying_app/src/services/customUserService.dart';
import 'package:roleplaying_app/src/services/file_upload_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/fetch_info.dart';

late CustomUserModel _user;

class UserProfileScreen extends StatefulWidget{
  CustomUserModel user;

  UserProfileScreen({Key? key, required this.user}) : super(key: key) {
    _user = user;
  }

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isOpen = false;
  late OverlayEntry _overlayEntry;
  late double x;
  late double y;


  openContextMenu() {
    isOpen = true;
    _overlayEntry = _createContextMenuOverlay();
    Overlay.of(context)!.insert(_overlayEntry);
  }

  closeContextMenu() {
    isOpen = false;
    _overlayEntry.remove();
  }

  update() {
    setState(() {

    });
  }

  updateImage() async {
    closeContextMenu();
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    _user.image = "user_pic";
    CustomUserService().updateCustomUser(_user);
    TaskState state = await FileUploadService().uploadImage(_user.idUser, image!.path, "user_pic");
    if (state == TaskState.success) {
      setState(() {

      });
    }
  }

  OverlayEntry _createContextMenuOverlay() {
    return OverlayEntry(builder: (context) {
      return GestureDetector(
        onTap: closeContextMenu,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            color: const Color(0x00ffffff),
            child: Stack(
              children: [
                Positioned(
                  left: x,
                  top: y,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                spreadRadius: 5,
                                offset: const Offset(5, 5),
                                blurRadius: 10
                            )
                          ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextButton(
                          child: Text("Сменить картинку", style: Theme.of(context).textTheme.subtitle1),
                          onPressed: () {
                            updateImage();
                          },
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),
        )
      );
    });
  }

  getCoordinates(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
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
                             Listener(
                               onPointerMove: getCoordinates,
                               onPointerDown: getCoordinates,
                               onPointerUp: getCoordinates,
                               child: IconButton(
                                 iconSize: sqrt(MediaQuery.of(context).size.height)*8,
                                 icon: FutureBuilder<String>(
                                   future: FileUploadService().getImage(_user.idUser, _user.image),
                                     builder: (context, snapshot) {
                                   if (!snapshot.hasData) {
                                     return const CircularProgressIndicator();
                                   } else if (snapshot.hasError) {
                                     return Text(snapshot.error.toString());
                                   } else {
                                     return Container(
                                       decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           border: Border.all(width: 0),
                                           image: DecorationImage(
                                             fit: BoxFit.fitHeight,
                                             alignment: FractionalOffset.topCenter,
                                             image: NetworkImage(snapshot.data!),
                                           )
                                       ),
                                     );
                                   }
                                 }),
                                 onPressed: ()
                                 {
                                   openContextMenu();
                                 },
                               ),
                             ),
                             Padding(
                                 padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 40),
                                 child: Center(
                                   child: SizedBox(
                                       height: MediaQuery.of(context).size.height / 10,
                                       width: MediaQuery.of(context).size.width / 2,
                                       child: Padding(
                                           padding: const EdgeInsets.only(right: 25),
                                           child: Text(
                                               _user.nickName,
                                               textAlign: TextAlign.center,
                                               style: Theme.of(context).textTheme.headline2
                                           )
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
                                           child: Text(state.getUser()!.id == _user.idUser ? "Мои анкеты" : "Анкеты пользователя",
                                             style: Theme.of(context).textTheme.headline2,
                                           ),
                                         ),
                                         Padding(
                                             padding: const EdgeInsets.only(left: 20, top: 35),
                                             child: FetchInfoFromDb.itemOfProfilesList(_user.idUser)
                                         ),
                                         state.getUser()!.id == _user.idUser ? Positioned(
                                             right: 5,
                                             top: 5,
                                             child: utils.PushButton(icon: Icons.add, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.create())))
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