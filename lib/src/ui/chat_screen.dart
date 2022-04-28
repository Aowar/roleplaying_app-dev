import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';
import 'package:roleplaying_app/src/models/message.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/customUserService.dart';
import 'package:roleplaying_app/src/services/message_service.dart';
import 'package:roleplaying_app/src/ui/Utils.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_description_screen.dart';
import 'package:roleplaying_app/src/ui/chat_edit_screen.dart';
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
  final MessageService _messageService = MessageService(_chat!);
  final CustomUserService _customUserService  = CustomUserService();

  ///Getting list stream of messages
  Stream<List<Message>> _readMessages() {
    return FirebaseFirestore.instance.collection("chats").doc(_chat!.id).collection("messages").orderBy('creationDate', descending: false).snapshots().map(
            (snapshot) =>
            snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList()
    );
  }

  ///Getting messages from DB
  itemOfMessagesList(AuthState state) {
    return StreamBuilder<List<Message>>(
      stream: _readMessages(),
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
                    if (state.getUser()!.id == messages[index].authorId) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: curUserMessageBox(messages[index].text, messages[index].authorId),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: messageBox(messages[index].text, messages[index].authorId),
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

  Stream<List<CustomUserModel>> _readUser(String userId) => FirebaseFirestore.instance.collection("users").where("userId", isEqualTo:  userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => CustomUserModel.fromJson(doc.data())).toList()
  );

  ///Getting message author
  authorOfMessage(String userId) {
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
                        return Text(user[index].nickName.toString(), style: Theme.of(context).textTheme.subtitle1);
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

  ///Message box
  Widget messageBox(String text, String userId) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Stack(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 6, maxWidth: MediaQuery.of(context).size.width / 1.2),
          child: Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
              depth: 2.0,
              color: Theme.of(context).accentColor,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: Utils.GenerateButton2(Icons.account_circle_sharp, context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: userId))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 100, left: MediaQuery.of(context).size.width / 5),
                  child: authorOfMessage(userId)
                ),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 20, left: MediaQuery.of(context).size.width / 5, right: 5, bottom: 10),
                    child: Text(text,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                )
              ],
            ),
          ),
        ),
      ],
    )
  );

  ///Generate message box where current logged user id = message author id
  Widget curUserMessageBox(String text, String userId) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 6, maxWidth: MediaQuery.of(context).size.width / 1.2),
            child: Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                depth: 2.0,
                color: Theme.of(context).accentColor,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Utils.GenerateButton2(Icons.account_circle_sharp, context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: userId))),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 100, right: MediaQuery.of(context).size.width / 5),
                      child: authorOfMessage(userId)
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 20, left: 5, right: MediaQuery.of(context).size.width / 5, bottom: 10),
                      child: Text(text,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyText1,
                      )
                  )
                ],
              ),
            ),
          ),
        ],
      ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState> (
        builder: (context, state) {
          if (state is AuthStateAuthetificated) {
            return Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Utils.GenerateBackButton(context),
                  ),
                  Positioned(
                    right: 15,
                    top: 15,
                    child: Utils.GenerateButton2(Icons.menu, context, MaterialPageRoute(builder: (context) => ChatDescriptionScreen(chat: _chat))),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 1.24,
                        child: Neumorphic(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                            depth: 2.0,
                            color: Theme.of(context).cardColor,
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
                                                    itemOfMessagesList(state)
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
                                                            child: Neumorphic(
                                                                style: NeumorphicStyle(
                                                                    shape: NeumorphicShape.convex,
                                                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                                                                    depth: 5.0,
                                                                    color: Theme.of(context).accentColor
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
                                                      child: Neumorphic(
                                                        style: NeumorphicStyle(
                                                          shape: NeumorphicShape.flat,
                                                          depth: 5.0,
                                                          color: Theme.of(context).primaryColor,
                                                          boxShape: const NeumorphicBoxShape.circle(),
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                                                          color: Colors.white,
                                                          iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                                                          onPressed: () async {
                                                            String _text = _textController.text;
                                                            Message _message = Message(state.getUser()!.id, _text);
                                                            _messageService.addMessage(_message);
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
            );
          }
          else {
            return AuthScreen();
          }
        }
    );
  }
}