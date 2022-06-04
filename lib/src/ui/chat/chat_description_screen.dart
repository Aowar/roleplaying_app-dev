import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/custom_user_model.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/custom_user_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/chat/approving_profiles_screen.dart';
import 'package:roleplaying_app/src/ui/grid_screen/users_in_chat_grid_screen.dart';
import 'package:roleplaying_app/src/ui/profile/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat/chat_edit_screen.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart';
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/fetch_info.dart';


import '../../services/auth_service.dart';

class ChatDescriptionScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  final Chat chat;

  ChatDescriptionScreen({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatDescriptionView(chat: chat);
  }
}

class ChatDescriptionView extends StatefulWidget {
  final Chat chat;
  const ChatDescriptionView({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatDescriptionView> createState() => _ChatDescriptionView();
}

class _ChatDescriptionView extends State<ChatDescriptionView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String text;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder <AuthBloc, AuthState> (
        builder: (context, state) {
          if (state is AuthStateAuthenticated) {
            return StreamBuilder<Chat>(
              stream: ChatService().readChat(widget.chat.id),
              builder: (context, snapshot) {
                late Chat _chat;
                if(snapshot.hasData){
                  _chat = snapshot.data!;
                }
                return Scaffold(
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
                          top: 16,
                          left: 16,
                          child: utils.BackButton(),
                      ),
                      if(!snapshot.hasData) ...[
                        const CircularProgressIndicator()
                      ] else if(snapshot.hasError) ...[
                        utils.Toasts.showErrorMessage(errorMessage: "Ошибка загрущки описания"),
                        Container()
                      ] else ...[
                        _chat.isPrivate || _chat.organizerId == state.getUser()!.id ? Positioned(
                          top: 16,
                          right: 16,
                          child: utils.PushButton(icon: Icons.edit, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatEditScreen.update(chat: _chat)))),
                        ) : Container(),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.1,
                              height: MediaQuery.of(context).size.height / 1.2,
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
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 5, top: 2, bottom: 2, right: 5),
                                                        child: TextField(
                                                          style: TextStyle(
                                                              fontStyle: Theme.of(context).textTheme.headline2!.fontStyle,
                                                              color: Theme.of(context).textTheme.subtitle2!.color,
                                                              fontSize: 24
                                                          ),
                                                          maxLines: 1,
                                                          textAlignVertical: TextAlignVertical.center,
                                                          textAlign: TextAlign.center,
                                                          decoration: const InputDecoration(
                                                            border: InputBorder.none,
                                                            hintText: "Название чата",
                                                          ),
                                                          controller: _titleController..text = _chat.title,
                                                          readOnly: true,
                                                        ),
                                                      )
                                                  )
                                              ),
                                            ),
                                            ///image container
                                            Padding(
                                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                                child: SizedBox.square(
                                                  dimension: sqrt(MediaQuery.of(context).size.width + MediaQuery.of(context).size.height) * 8,
                                                  child: FutureBuilder<String>(
                                                    future: FileService().getChatImage(_chat.id, _chat.image, _chat.isPrivate),
                                                    builder: (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return const LinearProgressIndicator();
                                                      } else if (snapshot.hasError) {
                                                        Fluttertoast.showToast(
                                                            msg: "Ошибка загрузки изображения",
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
                                                              color: Theme.of(context).colorScheme.secondaryContainer,
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
                                                        color: Theme.of(context).colorScheme.secondaryContainer,
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(5.0),
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
                                                      padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
                                                      child: TextField(
                                                        style: Theme.of(context).textTheme.bodyText2,
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
                                                      ),
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                          ///Patterns block
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15),
                                            child: Container(
                                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.4),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.2,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context).canvasColor,
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Theme.of(context).canvasColor.withOpacity(0.2),
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
                                                        child: Text("Шаблоны анкет",
                                                          style: Theme.of(context).textTheme.headline2,
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding: const EdgeInsets.only(left: 20, top: 35),
                                                          child: ProfilesList(userId: state.getUser()!.id, stream: ProfileService().readProfilesPatterns(_chat.id))
                                                      ),
                                                      state.getUser()!.id == _chat.organizerId ? Positioned(
                                                          right: 5,
                                                          top: 5,
                                                          child: PushButton(
                                                              icon: Icons.add,
                                                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.create(currentUserId: state.getUser()!.id, isPattern: true, chatId: _chat.id,)))
                                                          )
                                                      ) : Container()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ///Approved profiles block
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15),
                                            child: Container(
                                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.4),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.2,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context).canvasColor,
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Theme.of(context).canvasColor.withOpacity(0.2),
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
                                                        child: Text("Одобренные анкеты",
                                                          style: TextStyle(
                                                            color: Theme.of(context).textTheme.headline2!.color,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding: const EdgeInsets.only(left: 20, top: 35),
                                                          child: ProfilesList(userId: state.getUser()!.id, stream: ProfileService().readApprovedProfiles(_chat.id))
                                                      ),
                                                      state.getUser()!.id == _chat.organizerId ? Positioned(
                                                          right: 5,
                                                          top: 5,
                                                          child: PushButton(
                                                              icon: Icons.add,
                                                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovingScreen(chatId: _chat.id)))
                                                          )
                                                      ) : Container()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ///Users container
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15, bottom: 10),
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
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width / 1.3,
                                                        child: Container(
                                                          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 10, maxHeight: MediaQuery.of(context).size.height / 2),
                                                          child: GridView.builder(
                                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 3,
                                                            ),
                                                            itemCount: _chat.usersId.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              ///User
                                                              return Padding(
                                                                padding: index == 0 || index == 1 || index == 2 ? const EdgeInsets.only(top: 10) : const EdgeInsets.only(top: 0),
                                                                child: FutureBuilder<CustomUserModel>(
                                                                    future: CustomUserService().getUser(_chat.usersId[index]),
                                                                    builder: (context, snapshot) {
                                                                      if (!snapshot.hasData) {
                                                                        return SizedBox.square(
                                                                          dimension: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width) * 1.5,
                                                                          child: Container(
                                                                            decoration: BoxDecoration(
                                                                              color: Theme.of(context).colorScheme.primaryContainer,
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(width: 2, color: Theme.of(context).colorScheme.primaryContainer),
                                                                            ),
                                                                            child: const CircularProgressIndicator(),
                                                                          ),
                                                                        );
                                                                      } else if (snapshot.hasError) {
                                                                        return SizedBox.square(
                                                                          dimension: sqrt(MediaQuery.of(context).size.height+MediaQuery.of(context).size.width) * 1.5,
                                                                          child: Container(
                                                                            decoration: BoxDecoration(
                                                                              color: Theme.of(context).colorScheme.primaryContainer,
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(width: 2, color: Theme.of(context).colorScheme.primaryContainer),
                                                                            ),
                                                                            child: const Icon(Icons.account_circle_sharp),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return Column(
                                                                          children: [
                                                                            utils.CustomCircleIconButton(
                                                                                future: FileService().getUserImage(snapshot.data!.idUser, snapshot.data!.image),
                                                                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(user: snapshot.data!))),
                                                                                borderWidth: 2,
                                                                                scale: 1.5
                                                                            ),
                                                                            Text(snapshot.data!.nickName,
                                                                                style: Theme.of(context).textTheme.subtitle2
                                                                            )
                                                                          ],
                                                                        );
                                                                      }
                                                                    }
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                              ),
                                            )
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: state.getUser()!.id != _chat.organizerId ? BuildExitButton(deleteFlag: false, userId: state.getUser()!.id, chat: _chat) : BuildExitButton(deleteFlag: true, userId: state.getUser()!.id, chat: _chat)
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
                      ]
                    ],
                  ),
                );
              }
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
  final Chat chat;
  const BuildExitButton({Key? key, required this.deleteFlag, required this.userId, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (deleteFlag) {
      return ElevatedButton(
        child: Text("Удалить чат", style: Theme.of(context).textTheme.bodyText2),
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.errorContainer
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => MyDialog(deleteFlag: deleteFlag, userId: userId, chat: chat)
          );
        },
      );
    } else {
      return ElevatedButton(
        child: Text("Выйти", style: Theme.of(context).textTheme.bodyText1),
        style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.errorContainer
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: ListTile(
                  title: Text(
                      "Вы точно хотите Выйти из чата",
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
                            ChatService().deleteUserFromChat(chat, userId);
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
      );
    }
  }
}

class MyDialog extends StatefulWidget {
  final bool deleteFlag;
  final String userId;
  final Chat chat;
  const MyDialog({Key? key, required this.deleteFlag, required this.userId, required this.chat}) : super(key: key);

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  bool deleteProfilesPatterns = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ListTile(
        title: Text(
            "Вы точно хотите удалить чат?",
            style: TextStyle(
                color: Theme.of(context).textTheme.subtitle2!.color,
                fontSize: 18
            )
        ),
      ),
      actions: <Widget>[
        Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Удалить шаблоны:",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.subtitle2!.color,
                      fontSize: 14
                  )
                ),
                Checkbox(
                    value: deleteProfilesPatterns,
                    onChanged: (bool? value) {
                      deleteProfilesPatterns = value!;
                      setState(() {});
                    }
                ),
              ]
          ),
        ),
        Center(
            child: ElevatedButton(
                onPressed: () {
                  if (deleteProfilesPatterns) {
                    ProfileService().deleteProfilesPatterns(widget.chat.profilesPatterns!);
                  }
                  ChatService().deleteChat(widget.chat.id);
                  if (widget.chat.isPrivate) {
                    FileService().deleteImage("chats/" + widget.chat.id, widget.chat.image);
                  }
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MenuScreen()), (route) => false);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)
                ),
                child: Text("Да", style: Theme.of(context).textTheme.bodyText2)
            )
        )
      ],
    );
  }
}
