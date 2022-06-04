import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;

late bool _chatCreateFlag;
late Chat _chat;
late XFile? imageInMemory;

class ChatEditScreen extends StatelessWidget {
  Chat? chat;
  ChatEditScreen.create({Key? key}) : super(key: key) {
    imageInMemory = null;
    _chatCreateFlag = true;
  }

  ChatEditScreen.update({Key? key, required this.chat}) : super(key: key) {
    imageInMemory = null;
    _chatCreateFlag = false;
    _chat = chat!;
  }

  @override
  Widget build(BuildContext context) {
    return const ChatEditView();
  }
}

class ChatEditView extends StatefulWidget {
  const ChatEditView({Key? key}) : super(key: key);

  @override
  State<ChatEditView> createState() => _ChatEditView();
}

class _ChatEditView extends State<ChatEditView> {
  final ChatService _chatService = ChatService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String title;
  late String description;
  bool isOpen = false;
  bool isLoading = false;
  bool imageChanged = false;
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
    final AuthBloc authBloc = context.read<AuthBloc>();
    final user = authBloc.state.getUser()!.id;
    return BlocBuilder <AuthBloc, AuthState> (
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
                    ///Back button
                    const Positioned(
                        top: 15,
                        left: 16,
                        child: utils.BackButton()
                    ),
                    ///Apply button
                    Positioned(
                        top: 15,
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
                                    blurRadius: 10,
                                )
                              ]
                          ),
                          child: isLoading ? const CircularProgressIndicator() :
                          IconButton(
                            icon: const Icon(Icons.check),
                            color: Colors.white,
                            iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              title = _titleController.text.trim();
                              description = _descriptionController.text;
                              List usersList = [];
                              if (_chatCreateFlag) {
                                usersList = [user];
                                 if (imageInMemory == null)
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
                              } else {
                                _chat.image = "chat_pic";
                                _chat.title = title;
                                _chat.description = description;
                              }
                              Chat chat = Chat(
                                  usersId: usersList,
                                  organizerId: state.getUser()!.id,
                                  title: title,
                                  description: description,
                                  image: "chat_pic"
                              );
                              if (!_chatCreateFlag) {
                                _chatService.updateChat(_chat);
                                await FileService().uploadImage("chats/" + _chat.id, imageInMemory!.path, "chat_pic");
                              } else {
                                await _chatService.addChat(chat, imageInMemory!.path);
                              }
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.pop(context);
                            },
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
                                        ///Title block
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: SizedBox(
                                              child: Container(
                                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
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
                                                child: TextField(
                                                  style: TextStyle(
                                                      fontStyle: Theme.of(context).textTheme.headline2!.fontStyle,
                                                      color: Theme.of(context).textTheme.bodyText2!.color,
                                                      fontSize: 24
                                                  ),
                                                  maxLines: 1,
                                                  textAlignVertical: TextAlignVertical.center,
                                                  textAlign: TextAlign.center,
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Название чата",
                                                  ),
                                                  controller: !_chatCreateFlag ? (_titleController..text = _chat.title) : _titleController,
                                                  onChanged: (String value) async {
                                                    if (!_chatCreateFlag) {
                                                      _chat.title = value.trim();
                                                    }
                                                    return;
                                                  },
                                                ),
                                              )
                                          ),
                                        ),
                                        ///image container
                                        Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                          child: SizedBox(
                                              child: Listener(
                                                onPointerMove: getCoordinates,
                                                onPointerDown: getCoordinates,
                                                onPointerUp: getCoordinates,
                                                child: IconButton(
                                                  iconSize: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width)*8,
                                                  icon: imageInMemory == null && _chatCreateFlag ?
                                                  Container(
                                                    child: const Icon(Icons.image_outlined),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(5.0),
                                                      ),
                                                    ),
                                                  ) :
                                                  !_chatCreateFlag && imageInMemory == null ?
                                                  FutureBuilder<String>(
                                                      future: FileService().getChatImage(_chat.id, _chat.image, _chat.isPrivate),
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
                                                                color: Theme.of(context).colorScheme.secondaryContainer,
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
                                        )
                                      ]
                                  ),
                                  Column(
                                    children: [
                                      ///Text body container
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 60),
                                        child: Container(
                                          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4),
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
                                                  padding: const EdgeInsets.only(left: 5, bottom:5, right: 5),
                                                  child: TextField(
                                                    style: Theme.of(context).textTheme.bodyText2,
                                                    keyboardType: TextInputType.multiline,
                                                    maxLines: null,
                                                    decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: "Текст",
                                                        hintStyle: TextStyle(
                                                          color: Theme.of(context).textTheme.subtitle2!.color,
                                                        )
                                                    ),
                                                    controller: !_chatCreateFlag ? (_descriptionController..text = _chat.description) : _descriptionController,
                                                    onChanged: (String value) async {
                                                      if (!_chatCreateFlag) {
                                                        _chat.description = value;
                                                      }
                                                      return;
                                                    },
                                                  ),
                                                )
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          else {
            return AuthScreen();
          }
        }
    );
  }
}