import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart';

import '../../services/auth_service.dart';

late Profile _profile;
late bool _profileCreateFlag;
late XFile? imageInMemory;

class ProfileEditScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  Profile? profile;
  final bool isPattern;
  final String currentUserId;
  String? chatId;

  ProfileEditScreen.edit({Key? key, required this.profile, this.isPattern = false, required this.currentUserId}) : super(key: key) {
    _profile = profile!;
    imageInMemory = null;
    _profileCreateFlag = false;
  }
  ProfileEditScreen.create({Key? key, this.isPattern = false, required this.currentUserId, this.chatId}) : super(key: key) {
    imageInMemory = null;
    _profileCreateFlag = true;
  }

  @override
  Widget build(BuildContext context) {
    if(!_profileCreateFlag) {
      if (profile!.userId != currentUserId && profile!.isPattern) {
        utils.Toasts.showInfo(context: context, infoMessage: "Вы редактируете копию шаблона, после редактирования анкета добавится к вашим анкетам");
      }
    }
    return ProfileEditView(isPattern: isPattern, currentUserId: currentUserId, chatId: chatId);
  }
}

class ProfileEditView extends StatefulWidget {
  final bool isPattern;
  final String currentUserId;
  final String? chatId;
  const ProfileEditView({Key? key, this.isPattern = false, required this.currentUserId, required this.chatId}) : super(key: key);

  @override
  State<ProfileEditView> createState() => _ProfileEditView();
}

class _ProfileEditView extends State<ProfileEditView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  late String title;
  late String text;
  bool isOpen = false;
  bool imageChanged = false;
  bool isLoading = false;
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

  updateImage() async {
    closeContextMenu();
    XFile? image;
    final ImagePicker _picker = ImagePicker();
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return setState(() { });
    } else {
      imageChanged = true;
      return imageInMemory = image;
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
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).canvasColor.withOpacity(0.2),
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateAuthenticated) {
          return KeyboardDismissOnTap(
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
                  ///Building back button
                  const Positioned(
                      top: 16,
                      left: 16,
                      child: utils.BackButton()
                  ),
                  ///Building apply button
                  Positioned(
                      top: 16,
                      right: 16,
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
                        child: isLoading ? const CircularProgressIndicator() : IconButton(
                            icon: const Icon(Icons.check),
                            color: Colors.white,
                            iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                            onPressed: () async {
                              title = _titleController.text.trim();
                              text = _textController.text;
                              if (imageInMemory == null && _profileCreateFlag)
                              {
                                Fluttertoast.showToast(
                                    msg: "Добавьте картинку",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                                return;
                              }
                              if (imageInMemory == null && _profile.isPattern && !_profileCreateFlag && state.getUser()!.id != _profile.userId) {
                                Toasts.showErrorMessage(errorMessage: "Замените картинку");
                                return;
                              }
                              isLoading = true;
                              setState(() {

                              });
                              if (_profileCreateFlag) {
                                _profile = Profile(
                                    userId: state.getUser()!.id,
                                    title: title,
                                    text: text,
                                    image: "profile_pic"
                                );
                                if (widget.isPattern) {
                                  _profile.isPattern = widget.isPattern;
                                  _profile.approvementState = ApprovementStates.approved.value;
                                  _profile.chatId = widget.chatId!;
                                }
                                String patternId = await ProfileService().addProfile(_profile, imageInMemory!.path);
                                if(widget.isPattern) {
                                  ChatService().addProfilePattern(widget.chatId!, patternId);
                                }
                              } else {
                                _profile.approvementState = ApprovementStates.awaiting.value;
                                _profile.title = title;
                                _profile.text = text;
                                if(_profile.isPattern){
                                  if(_profile.userId != state.getUser()!.id) {
                                    _profile.userId = state.getUser()!.id;
                                    _profile.isPattern = false;
                                    _profile.approvementState = ApprovementStates.awaiting.value;
                                    ProfileService().addProfile(_profile, imageInMemory!.path);
                                  } else {
                                    ProfileService().updateProfile(_profile);
                                    if(imageChanged) {
                                      FileService().uploadImage("profiles/" + _profile.id, imageInMemory!.path, _profile.image);
                                    }
                                  }
                                }
                              }
                              Navigator.pop(context);
                            }
                        ),
                      )
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 1.15,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
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
                          child: Center(
                            child: ListView(
                              children: [
                                Column(
                                  children: [
                                    ///Image container
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            child: Listener(
                                              onPointerMove: getCoordinates,
                                              onPointerDown: getCoordinates,
                                              onPointerUp: getCoordinates,
                                              child: IconButton(
                                                iconSize: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width)*3,
                                                icon: imageInMemory == null && _profileCreateFlag ?
                                                Container(
                                                  child: const Icon(Icons.image_outlined),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                                    borderRadius: const BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ) :
                                                !_profileCreateFlag && imageInMemory == null ?
                                                FutureBuilder<String>(
                                                    future: FileService().getProfileImage(_profile.id, _profile.image),
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
                                                        return const Icon(Icons.image_outlined);
                                                      } else {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0),
                                                              borderRadius: const BorderRadius.all(
                                                                Radius.circular(5.0),
                                                              ),
                                                              image: DecorationImage(
                                                                fit: BoxFit.fitHeight,
                                                                alignment: FractionalOffset.topCenter,
                                                                image: NetworkImage(snapshot.data!),
                                                              )
                                                          ),
                                                        );
                                                      }
                                                    }
                                                ) : FutureBuilder<Uint8List>(
                                                    future: imageInMemory!.readAsBytes(),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return const LinearProgressIndicator();
                                                      } if (snapshot.hasError) {
                                                        Fluttertoast.showToast(
                                                            msg: "Ошибка загрузки изображения" + snapshot.error.toString(),
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.CENTER,
                                                            timeInSecForIosWeb: 3,
                                                            backgroundColor: Colors.black26,
                                                            textColor: Colors.black,
                                                            fontSize: 16.0
                                                        );
                                                        return const Icon(Icons.image_outlined);
                                                      } else {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                  image: Image.memory(snapshot.data!).image
                                                              )
                                                          ),
                                                        );
                                                      }
                                                    }
                                                ),
                                                onPressed: ()
                                                {
                                                  openContextMenu();
                                                },
                                              ),
                                            ),
                                          ),
                                          ///Title block
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: SizedBox(
                                              child: Container(
                                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(10.0),
                                                      ),
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
                                                    padding: const EdgeInsets.only(left: 5, top: 2, bottom: 2, right: 5),
                                                    child: TextField(
                                                      maxLines: 1,
                                                      textAlignVertical: TextAlignVertical.center,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontStyle: Theme.of(context).textTheme.headline2!.fontStyle,
                                                          color: Theme.of(context).textTheme.subtitle2!.color,
                                                          fontSize: 20
                                                      ),
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: "Название",
                                                      ),
                                                      controller: !_profileCreateFlag ? (_titleController..text = _profile.title) : _titleController,
                                                      onChanged: (String value) async {
                                                        _profile.title = value.trim();
                                                      },
                                                    ),
                                                  )
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    ///Body text block
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80, bottom: 20),
                                      child: Container(
                                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 2),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width / 1.3,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.secondaryContainer,
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(5.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                                                        spreadRadius: 2,
                                                        offset: const Offset(5, 5),
                                                        blurRadius: 10
                                                    )
                                                  ]
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: TextField(
                                                  style: TextStyle(
                                                      color: Theme.of(context).textTheme.subtitle2!.color,
                                                      fontStyle: Theme.of(context).textTheme.bodyText1!.fontStyle
                                                  ),
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null,
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: "Текст",
                                                      hintStyle: TextStyle(
                                                        color: Theme.of(context).textTheme.subtitle2!.color,
                                                      )
                                                  ),
                                                  controller: !_profileCreateFlag ? (_textController..text = _profile.text) : _textController,
                                                  onChanged: (String value) async {
                                                    _profile.text = value;
                                                  },
                                                ),
                                              )
                                          ),
                                        ),
                                      ),
                                    ),
                                    !_profileCreateFlag && state.getUser()!.id == _profile.userId ? Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: ElevatedButton(
                                        child: Text("Удалить анкету", style: Theme.of(context).textTheme.bodyText2),
                                        style: ElevatedButton.styleFrom(
                                            primary: Theme.of(context).colorScheme.errorContainer
                                        ),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                content: ListTile(
                                                  title: Text(
                                                      "Вы точно хотите удалить анкету?",
                                                      style: TextStyle(
                                                          color: Theme.of(context).textTheme.subtitle2!.color,
                                                          fontSize: 18
                                                      )
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  Center(
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            if (_profile.isPattern) {
                                                              ChatService().deleteProfilePattern(_profile.chatId, _profile.id);
                                                            }
                                                            if (_profile.chatId != "none") {
                                                              ChatService().deleteApprovedProfile(_profile.chatId, _profile.id);
                                                            }
                                                            ProfileService().deleteProfile(_profile.id);
                                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MenuScreen()), (route) => false);
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)
                                                          ),
                                                          child: Text("Да", style: Theme.of(context).textTheme.bodyText2)
                                                      )
                                                  )
                                                ],
                                              )
                                          );
                                        },
                                      ),
                                    ) : Container()
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return AuthScreen();
      },
    );
  }
}