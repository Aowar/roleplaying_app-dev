import 'dart:developer' as dev;
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/custom_user_model.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/custom_user_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat/chat_screen.dart';
import 'package:roleplaying_app/src/ui/grid_screen/profile_grid_screen.dart';
import 'package:roleplaying_app/src/ui/profile/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/settings_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/fetch_info.dart';

class UserProfileScreen extends StatefulWidget{
  CustomUserModel user;

  UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late CustomUserModel _user;
  bool isMenuOpen = false;
  late OverlayEntry _overlayEntry;
  late double x;
  late double y;


  openContextMenu(String curUserId) {
    isMenuOpen = true;
    _overlayEntry = _createContextMenuOverlay(curUserId);
    Overlay.of(context)!.insert(_overlayEntry);
  }

  closeContextMenu() {
    isMenuOpen = false;
    _overlayEntry.remove();
  }

  updateImage() async {
    closeContextMenu();
    XFile? image;
    final ImagePicker _picker = ImagePicker();
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return setState(() { });
    } else {
      _user.image = "loading";
      CustomUserService().updateCustomUser(_user);
      TaskState state = await FileService().uploadImage("users/" + _user.idUser, image.path, "user_pic");
      _user.image = "user_pic";
      CustomUserService().updateCustomUser(_user);
      if (state == TaskState.success) {
        setState(() { });
      }
    }
  }

  OverlayEntry _createContextMenuOverlay(String curUserId) {
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
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                                spreadRadius: 5,
                                offset: const Offset(5, 5),
                                blurRadius: 10
                            )
                          ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: curUserId == _user.idUser ? TextButton(
                          child: Text("Сменить картинку", style: Theme.of(context).textTheme.subtitle1),
                          onPressed: () {
                            updateImage();
                          },
                        ) : null,
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
    _user = widget.user;
    return BlocBuilder<AuthBloc, AuthState> (
         builder: (context, state) {
           if (state is AuthStateAuthenticated) {
             return WillPopScope(
               onWillPop: () async {
                 if(isMenuOpen) {
                   closeContextMenu();
                 }
                 return true;
               },
               child: Scaffold(
                 body: Stack(
                   children: [
                     SizedBox(
                       width: MediaQuery.of(context).size.width,
                       height: MediaQuery.of(context).size.height,
                       child: Container(
                         decoration: BoxDecoration(
                             gradient: LinearGradient(
                                 colors: [
                                   Theme.of(context).backgroundColor,
                                   Theme.of(context).colorScheme.secondary
                                 ],
                                 begin: Alignment.bottomLeft,
                                 end: Alignment.topRight
                             )
                         ),
                       ),
                     ),
                     const Positioned(
                         left: 16,
                         top: 16,
                         child: utils.BackButton()
                     ),
                     state.getUser()!.id == _user.idUser ?
                     Positioned(
                         right: 16,
                         top: 16,
                         child: utils.PushButton(
                             icon: Icons.settings,
                             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(user: _user)))
                         )
                     ) : Container(),
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
                                   iconSize: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width)*6,
                                   icon: FutureBuilder<String>(
                                       future: FileService().getUserImage(_user.idUser, _user.image),
                                       builder: (context, snapshot) {
                                         if (!snapshot.hasData) {
                                           return const CircularProgressIndicator();
                                         } else if (snapshot.hasError) {
                                           Fluttertoast.showToast(
                                               msg: "Ошибка загрузки изображения" + snapshot.error.toString(),
                                               toastLength: Toast.LENGTH_SHORT,
                                               gravity: ToastGravity.CENTER,
                                               timeInSecForIosWeb: 3,
                                               backgroundColor: Colors.black26,
                                               textColor: Colors.black,
                                               fontSize: 16.0
                                           );
                                           return const Icon(Icons.account_circle_sharp);
                                         } else {
                                           return Container(
                                             decoration: BoxDecoration(
                                                 color: Theme.of(context).primaryColor,
                                                 shape: BoxShape.circle,
                                                 border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                                                 image: _user.image != "loading" ? DecorationImage(
                                                   fit: BoxFit.fitHeight,
                                                   alignment: FractionalOffset.topCenter,
                                                   image: NetworkImage(snapshot.data!),
                                                 ) : null
                                             ),
                                             child: _user.image == "loading" ? const CircularProgressIndicator() : null,
                                           );
                                         }
                                       }
                                   ),
                                   onPressed: ()
                                   {
                                     openContextMenu(state.getUser()!.id);
                                   },
                                 ),
                               ),
                               Padding(
                                   padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 60),
                                   child: Center(
                                     child: SizedBox(
                                         width: MediaQuery.of(context).size.width / 2,
                                         child: Text(
                                             _user.nickName,
                                             textAlign: TextAlign.center,
                                             style: Theme.of(context).textTheme.headline1
                                         )
                                     ),
                                   )
                               ),
                               state.getUser()!.id != _user.idUser ? Padding(
                                 padding: const EdgeInsets.only(top: 0),
                                 child: SizedBox(
                                   width: MediaQuery.of(context).size.width / 2.5,
                                   child: ElevatedButton(
                                     style: ButtonStyle(
                                       backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                         RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(15)
                                         )
                                       )
                                     ),
                                     onPressed: () async {
                                       List<String> usersList = [state.getUser()!.id, _user.idUser];
                                       if(!await ChatService().isPrivateChatExists(usersList)) {
                                         Chat chat = Chat(
                                             usersId: usersList,
                                             organizerId: state.getUser()!.id,
                                             title:  "Чат " + state.getUser()!.nickName!,
                                             description: "Личный чат между пользователями " + state.getUser()!.nickName! + " и " + _user.nickName,
                                             image: "default_image.png",
                                             isPrivate: true
                                         );
                                         chat = await ChatService().addChat(chat);
                                         Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)));
                                       } else {
                                         utils.Toasts.showInfo(context: context, infoMessage: "Вы уже начали чат с этим пользователем");
                                       }
                                     },
                                     child: Center(
                                       child: Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: const [
                                           Text(
                                               "Написать"
                                           ),
                                           Icon(Icons.edit)
                                         ],
                                       ),
                                     )
                                   ),
                                 )
                               ) : Container(),
                               Padding(
                                 padding: const EdgeInsets.only(top: 25),
                                 child: GestureDetector(
                                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilesGridScreen(userId: _user.idUser))),
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
                                     constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.1),
                                     child: Stack(
                                       children: [
                                         Container(
                                           constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.45),
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
                                                       child: ProfilesList(userId: _user.idUser)
                                                   ),
                                                   state.getUser()!.id == _user.idUser ? Positioned(
                                                       right: 5,
                                                       top: 5,
                                                       child: utils.PushButton(icon: Icons.add, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.create(currentUserId: state.getUser()!.id))))
                                                   ) : Container()
                                                 ],
                                               ),
                                             ),
                                           ),
                                         ),
                                         const Positioned(
                                             bottom: 8,
                                             right: 10,
                                             child: Text(
                                                 "Открыть блок",
                                                 maxLines: 1,
                                                 style: TextStyle(
                                                   color: Colors.blue,
                                                   fontSize: 12,
                                                   decoration: TextDecoration.underline,
                                                 )
                                             )
                                         )
                                       ],
                                     ),
                                   ),
                                 ),
                               )
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
               ),
             );
           }
           return AuthScreen();
         });
  }
}