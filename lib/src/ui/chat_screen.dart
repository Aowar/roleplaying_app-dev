import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/custom_user_model.dart';
import 'package:roleplaying_app/src/models/message.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/custom_user_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/services/message_service.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_description_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';

late Chat? _chat;

class ChatScreen extends StatefulWidget {
  final Chat? chat;
  ChatScreen({Key? key, required this.chat}) : super(key: key) {
    _chat = chat;
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final MessageService messageService = MessageService(_chat!);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState> (
        builder: (context, state) {
          if (state is AuthStateAuthenticated && _chat!.usersId.contains(state.getUser()!.id)) {
            return KeyboardDismissOnTap(
              child: Scaffold(
                body: Stack(
                  children: [
                    const Positioned(
                      left: 16,
                      top: 15,
                      child: utils.BackButton()
                    ),
                    Positioned(
                      right: 16,
                      top: 15,
                      child: FutureBuilder<Chat>(
                          future: ChatService().getChat(_chat!.id),
                          builder: (context, snapshot) {
                            if(!snapshot.hasData) {
                              return utils.PushButton(icon: Icons.menu, onPressed: () { });
                            } else {
                              Chat chat = snapshot.data!;
                              chat.id = _chat!.id;
                              return utils.PushButton(icon: Icons.menu, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDescriptionScreen(chat: chat))));
                            }
                          }
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 1.24,
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
                            child: Stack(
                              children: [
                                ListView(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 20),
                                        child: Column(
                                          children: [
                                            Column(
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width / 1.1 - 15,
                                                  height: MediaQuery.of(context).size.height / 1.6,
                                                  child: Stack(
                                                    children: [
                                                      ItemOfMessageList(loggedUserId: state.getUser()!.id, messageService: messageService)
                                                    ],
                                                  )
                                                )
                                              ],
                                            ),
                                            Center(
                                              child: Padding(
                                                  padding: EdgeInsets.only(top: 5, left: MediaQuery.of(context).size.width / 90),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                          width: MediaQuery.of(context).size.width / 1.35,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(context).size.width / 1.5,
                                                            child: Container(
                                                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 4.5),
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(context).colorScheme.secondary,
                                                                      borderRadius: const BorderRadius.all(
                                                                        Radius.circular(20.0),
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
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(left: 10),
                                                                    child: TextField(
                                                                        textAlign: TextAlign.left,
                                                                        keyboardType: TextInputType.multiline,
                                                                        maxLines: null,
                                                                        controller: _textController,
                                                                        decoration: InputDecoration(
                                                                            border: InputBorder.none,
                                                                            hintText: "Сообщение",
                                                                            hintStyle: TextStyle(
                                                                                color: Theme.of(context).textTheme.bodyText2?.color
                                                                            )
                                                                        )
                                                                    ),
                                                                  )
                                                              ),
                                                            ),
                                                          )
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 5),
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
                                                          child: IconButton(
                                                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                                                            color: Colors.white,
                                                            iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                                                            onPressed: () async {
                                                              String _text = _textController.text;
                                                              Message _message = Message(state.getUser()!.id, _text);
                                                              messageService.addMessage(_message);
                                                              _textController.clear();
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                              ),
                                            )
                                          ],
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
                    )
                  ],
                ),
              ),
            );
          }
          else if (state is AuthStateAuthenticated && !_chat!.usersId.contains(state.getUser()!.id)) {
            return Scaffold(
              body: Stack(
                children: [
                  const Positioned(
                    left: 15,
                    top: 15,
                    child: utils.BackButton()
                  ),
                  Center(
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
                      child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Вы ещё не вступили в чат",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                                            spreadRadius: 5,
                                            offset: const Offset(5, 5),
                                            blurRadius: 10
                                        )
                                      ]
                                  ),
                                  child: TextButton(
                                    child: Text("Вступить",
                                        style: Theme.of(context).textTheme.bodyText1
                                    ),
                                    onPressed: () async {
                                      await ChatService().addNewUserInChat(_chat!, state.getUser()!.id);
                                      _chat!.usersId.add(state.getUser()!.id);
                                      setState(() {
                                        ChatScreen(chat: _chat);
                                      });
                                    },
                                  )
                              )
                            ],
                          ),
                        )
                      ),
                    ),
                  )
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

///Getting messages from DB
class ItemOfMessageList extends StatelessWidget {
  final String loggedUserId;
  final MessageService messageService;

  const ItemOfMessageList({Key? key, required this.loggedUserId, required this.messageService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: messageService.readMessages(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
          final messages = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (loggedUserId == messages[index].authorId) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CurUserMessageBox(text: messages[index].text, userId: messages[index].authorId, currentUserId: loggedUserId),
                        ],
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: MessageBox(text: messages[index].text, userId: messages[index].authorId, currentUserId: loggedUserId),
                      );
                    }
                  },
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                ),
              )
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}


///Message box of logged user
class CurUserMessageBox extends StatelessWidget {
  final String text;
  final String userId;
  final String currentUserId;

  const CurUserMessageBox({Key? key, required this.text, required this.userId, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 6, maxWidth: MediaQuery.of(context).size.width / 1.2),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                        spreadRadius: 2,
                        offset: const Offset(5, 5),
                        blurRadius: 10
                    )
                  ]
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 5, right: MediaQuery.of(context).size.width / 5),
                    child: Column(
                      children: [
                        AuthorOfMessage(userId: userId, currentUserId: currentUserId),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(text,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 3,
                    child: FutureBuilder<CustomUserModel>(
                        future: CustomUserService().getUser(userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData){
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return utils.CustomCircleIconButton(
                                future: FileService().getUserImage(snapshot.data!.idUser, snapshot.data!.image),
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfileScreen(user: snapshot.data!))),
                                scale: 15,
                                borderWidth: 2,
                            );
                          }
                        }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///Message box
class MessageBox extends StatelessWidget {
  final String text;
  final String userId;
  final String currentUserId;

  const MessageBox({Key? key, required this.text, required this.userId, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 6, minHeight: MediaQuery.of(context).size.height / 8, maxWidth: MediaQuery.of(context).size.width / 1.2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Stack(
                children: [
                  FutureBuilder<CustomUserModel>(
                      future: CustomUserService().getUser(userId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData){
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return utils.CustomCircleIconButton(
                              future: FileService().getUserImage(snapshot.data!.idUser, snapshot.data!.image),
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfileScreen(user: snapshot.data!))),
                              borderWidth: 2,
                              scale: 15,
                          );
                        }
                      }
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 5, top: 5, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthorOfMessage(userId: userId, currentUserId: currentUserId),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(text,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}

///Getting message author
class AuthorOfMessage extends StatelessWidget {
  final String userId;
  final String currentUserId;

  const AuthorOfMessage({Key? key, required this.userId, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomUserModel>(
        future: CustomUserService().getUser(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text("Загрузка", style: Theme.of(context).textTheme.subtitle1),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle1),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text(snapshot.data!.nickName.toString(), style: Theme.of(context).textTheme.subtitle1, overflow: TextOverflow.fade),
            );
          }
        }
    );
  }
}