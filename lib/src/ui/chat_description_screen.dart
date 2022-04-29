import 'dart:math';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/ui/Utils.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_edit_screen.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';

import '../services/auth_service.dart';

late Chat _chat;

class ChatDescriptionScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  Chat? chat;

  ChatDescriptionScreen({Key? key, required this.chat}) : super(key: key) {
    _chat = chat!;
  }

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
    final AuthBloc authBloc = context.read<AuthBloc>();

    return BlocBuilder <AuthBloc, AuthState> (
        builder: (context, state) {
          if (state is AuthStateAuthenticated) {
            return Scaffold(
              body: Stack(
                children: [
                  Positioned(
                      top: 15,
                      left: 15,
                      child: Utils.GenerateBackButton(context),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Utils.GenerateButton2(Icons.menu, context, MaterialPageRoute(builder: (context) => ChatEditScreen.update(chat: _chat))),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 1.15,
                        child: Neumorphic(
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                            depth: 2.0,
                            color: Theme.of(context).cardColor,
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
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                  shape: NeumorphicShape.convex,
                                                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                                                  depth: 5.0,
                                                  color: Theme.of(context).accentColor
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
                                              child: NeumorphicButton(
                                                style: NeumorphicStyle(
                                                  shape: NeumorphicShape.flat,
                                                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                                  depth: 5.0,
                                                  color: Theme.of(context).accentColor,
                                                ),
                                                child: Icon(Icons.image_outlined,
                                                  size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*45),
                                                ),
                                                onPressed: () => Navigator.pushNamed(context, ''),
                                              )
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
                                          child: Neumorphic(
                                              style: NeumorphicStyle(
                                                shape: NeumorphicShape.flat,
                                                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                                depth: 2.0,
                                                color: Theme.of(context).accentColor,
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
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80, bottom: 20),
                                      child: Container(
                                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 8, maxHeight: MediaQuery.of(context).size.height / 7.5),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width / 1.3,
                                          child: Neumorphic(
                                              style: NeumorphicStyle(
                                                shape: NeumorphicShape.flat,
                                                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                                depth: 2.0,
                                                color: Theme.of(context).accentColor,
                                              ),
                                              ///User
                                              child: Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width / 1.3,
                                                        child: ListView.separated(
                                                          itemCount: _chat.usersId.length,
                                                          itemBuilder: (BuildContext context, int index) {
                                                            return Column(
                                                              children: [
                                                                NeumorphicButton(
                                                                  style: NeumorphicStyle(
                                                                    shape: NeumorphicShape.flat,
                                                                    boxShape: const NeumorphicBoxShape.circle(),
                                                                    depth: 5.0,
                                                                    color: Theme.of(context).accentColor,
                                                                  ),
                                                                  child:
                                                                  Icon(Icons.image_outlined,
                                                                    size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*2),
                                                                  ),
                                                                  onPressed: () => {},
                                                                  // onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: profile))),
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
