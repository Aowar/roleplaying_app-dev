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
import 'package:roleplaying_app/src/services/customUserService.dart';
import 'package:roleplaying_app/src/services/message_service.dart';
import 'package:roleplaying_app/src/ui/Utils.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_description_screen.dart';
import 'package:roleplaying_app/src/ui/chat_edit_screen.dart';

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
  late TextEditingController _textController;
  final MessageService _messageService = MessageService(_chat!);
  final CustomUserService _customUserService  = CustomUserService();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  Widget _getMessageList() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.height / 6,
      child: Stack(
        children: [
          Positioned(
              child: FirebaseAnimatedList(
                  query: _messageService.messageCollection,
                  itemBuilder: (context, snapshot, animation, index) {
                    return Container(child: messageBox(snapshot.children.elementAt(2).value.toString(), snapshot.children.elementAt(0).value.toString()));
                  }),
          )
        ],
      )
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
                      scrollDirection: Axis.horizontal,
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
                  child: Utils.GenerateButton('/profile_screen', Icons.account_circle_sharp, context),
                ),
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 100, left: MediaQuery.of(context).size.width / 8),
                  child: authorOfMessage(userId)
                ),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 20, left: MediaQuery.of(context).size.width / 8, right: 5, bottom: 10),
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
                                                width: MediaQuery.of(context).size.width / 1.1 - 20,
                                                height: MediaQuery.of(context).size.height / 1.6,
                                                child: _getMessageList()
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