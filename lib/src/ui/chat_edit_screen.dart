import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_screen.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';

import 'Utils.dart';

late bool _chatCreateFlag;
late Chat _chat;

class ChatEditScreen extends StatelessWidget {
  Chat? chat;
  ChatEditScreen.create({Key? key}) : super(key: key) {
    _chatCreateFlag = true;
  }

  ChatEditScreen.update({Key? key, required this.chat}) : super(key: key) {
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

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = context.read<AuthBloc>();
    final user = authBloc.state.getUser()!.id;
    return BlocBuilder <AuthBloc, AuthState> (
        builder: (context, state) {
          if (state is AuthStateAuthetificated) {
            return Scaffold(
              body: Stack(
                children: [
                  ///Back button
                  Positioned(
                      top: 15,
                      left: 15,
                      child: Utils.GenerateBackButton(context)
                  ),
                  ///Apply button
                  Positioned(
                      top: 15,
                      right: 15,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          depth: 5.0,
                          color: Theme.of(context).primaryColor,
                          boxShape: const NeumorphicBoxShape.circle(),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.check),
                          color: Colors.white,
                          iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                          onPressed: () async {
                            title = _titleController.text;
                            description = _descriptionController.text;
                            List usersList = [];
                            if (_chatCreateFlag) {
                              usersList = [user];
                            } else {
                              _chat.title = title;
                              _chat.description = description;
                            }
                            Chat chat = Chat(usersList, state.getUser()!.id, title, description);
                            !_chatCreateFlag ? _chatService.updateChat(_chat) : _chatService.addChat(chat);
                            !_chatCreateFlag ? Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat: _chat))) : Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen()));
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
                                        padding: const EdgeInsets.only(top: 30),
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
                                                textAlignVertical: TextAlignVertical.center,
                                                textAlign: TextAlign.center,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Название чата",
                                                ),
                                                controller: !_chatCreateFlag ? (_titleController..text = _chat.title) : _titleController,
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
                                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4),
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
                                                keyboardType: TextInputType.multiline,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Текст",
                                                    hintStyle: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyText1?.color,
                                                    )
                                                ),
                                                controller: !_chatCreateFlag ? (_descriptionController..text = _chat.description) : _descriptionController,
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
            );
          }
          else {
            return AuthScreen();
          }
        }
    );
  }
}