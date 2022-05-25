import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_edit_screen.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';

import '../services/auth_service.dart';

late Chat _chat;

class ChatDescriptionScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  final Chat chat;

  ChatDescriptionScreen({Key? key, required this.chat}) : super(key: key) {
    _chat = chat;
  }

  @override
  Widget build(BuildContext context) {
    return const ChatDescriptionView();
  }
}

class ChatDescriptionView extends StatefulWidget {
  const ChatDescriptionView({Key? key}) : super(key: key);

  @override
  State<ChatDescriptionView> createState() => _ChatDescriptionView();
}

class _ChatDescriptionView extends State<ChatDescriptionView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String title;
  late String text;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder <AuthBloc, AuthState> (
        builder: (context, state) {
          if (state is AuthStateAuthenticated) {
            return Scaffold(
              body: Stack(
                children: [
                  const Positioned(
                      top: 15,
                      left: 15,
                      child: utils.BackButton(),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: utils.PushButton(icon: Icons.edit, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatEditScreen.update(chat: _chat)))),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 1.1,
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
                                        padding: const EdgeInsets.only(top: 15),
                                        child: SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.5,
                                            height: MediaQuery.of(context).size.height / 22,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                                        spreadRadius: 5,
                                                        offset: const Offset(5, 5),
                                                        blurRadius: 10
                                                    )
                                                  ]
                                              ),
                                              child: TextField(
                                                readOnly: true,
                                                textAlignVertical: TextAlignVertical.center,
                                                textAlign: TextAlign.center,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Название чата",
                                                ),
                                                controller: _titleController..text = _chat.title,
                                              ),
                                            )
                                        ),
                                      ),
                                      ///image container
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                          child: SizedBox(
                                              width: sqrt(MediaQuery.of(context).size.width * 45),
                                              height: sqrt(MediaQuery.of(context).size.height * 45),
                                              child: FutureBuilder<String>(
                                                future: FileService().getChatImage(_chat.id, _chat.image),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return const LinearProgressIndicator();
                                                  } else if (snapshot.hasError) {
                                                    Fluttertoast.showToast(
                                                        msg: "Письмо отправлено на указанный адрес",
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 3,
                                                        backgroundColor: Colors.green,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0
                                                    );
                                                    return const Icon(Icons.image_outlined);
                                                  } else {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(context).colorScheme.secondary,
                                                          borderRadius: const BorderRadius.all(
                                                            Radius.circular(5.0),
                                                          ),
                                                          image: DecorationImage(
                                                            image: NetworkImage(snapshot.data!),
                                                            fit: BoxFit.fitHeight,
                                                            alignment: FractionalOffset.topCenter,
                                                          )
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                          )
                                      ),
                                    ]
                                ),
                                Column(
                                  children: [
                                    ///Text body container
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 60),
                                      child: Container(
                                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 3.4,),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width / 1.3,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(5.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                                        spreadRadius: 5,
                                                        offset: const Offset(5, 5),
                                                        blurRadius: 10
                                                    )
                                                  ]
                                              ),
                                              child: TextField(
                                                readOnly: true,
                                                keyboardType: TextInputType.multiline,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Текст",
                                                    hintStyle: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyText1?.color,
                                                    )
                                                ),
                                                controller: _descriptionController..text = _chat.description,
                                              )
                                          ),
                                        ),
                                      ),
                                    ),
                                    ///Users container
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80, bottom: 10),
                                      child: Container(
                                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 8, maxHeight: MediaQuery.of(context).size.height / 6.5),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width / 1.3,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(5.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                                        spreadRadius: 2,
                                                        offset: const Offset(5, 5),
                                                        blurRadius: 10
                                                    )
                                                  ]
                                              ),
                                              child: Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  ///User
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width / 1.3,
                                                        child: ListView.separated(
                                                          scrollDirection: Axis.horizontal,
                                                          itemCount: _chat.usersId.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            return Column(
                                                              children: [
                                                                ElevatedButton(
                                                                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserProfileScreen(user: _chat.usersId[index]))),
                                                                    child: Icon(Icons.account_circle_sharp,
                                                                      size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*2),
                                                                    ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    shape: const CircleBorder(),
                                                                    primary: Theme.of(context).cardColor
                                                                  )
                                                                ),
                                                                Padding(
                                                                    padding: const EdgeInsets.only(top: 10),
                                                                    child: Text(_chat.usersId[index],
                                                                        style: Theme.of(context).textTheme.subtitle2
                                                                    )
                                                                )
                                                              ],
                                                            );
                                                          },
                                                          separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                              )
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: state.getUser()!.id != _chat.organizerId ? BuildExitButton(deleteFlag: false, userId: state.getUser()!.id) : BuildExitButton(deleteFlag: true, userId: state.getUser()!.id)
                                    )
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
            );
          }
          else {
            return AuthScreen();
          }
        }
    );
  }
}

class BuildExitButton extends StatelessWidget {
  final bool deleteFlag;
  final String userId;
  const BuildExitButton({Key? key, required this.deleteFlag, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (deleteFlag) {
      return ElevatedButton(
        child: Text("Удалить чат", style: Theme.of(context).textTheme.bodyText1),
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).cardColor
        ),
        onPressed: () {
          ChatService().deleteChat(_chat.id);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
        },
      );
    } else {
      return ElevatedButton(
        child: Text("Выйти", style: Theme.of(context).textTheme.bodyText1),
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).cardColor
        ),
        onPressed: () {
          ChatService().deleteUserFromChat(_chat, userId);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
        },
      );
    }
  }
}
