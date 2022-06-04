import 'dart:math';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/notifications/notifications.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/services/notifications_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/profile/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/blocks_builder.dart';

import '../../services/auth_service.dart';
import '../auth_screen.dart';

late Profile _profile;

class ProfileScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  final Profile profile;

  ProfileScreen({Key? key, required this.profile}) : super(key: key) {
    _profile = profile;
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileView();
}

class _ProfileView extends State<ProfileView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  late String title = _profile.title;
  late String text = _profile.text;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateAuthenticated) {
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
                ///Building back button
                const Positioned(
                    top: 16,
                    left: 16,
                    child: utils.BackButton()
                ),
                ///Building edit button
                if (state.getUser()!.id == _profile.userId) ...[
                  Positioned(
                    top: 16,
                    right: 16,
                    child: utils.PushButton(icon: Icons.edit, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.edit(profile: _profile, currentUserId: state.getUser()!.id)))),
                  ),
                ] else if (_profile.isPattern) ...[
                  Positioned(
                    top: 16,
                    right: 16,
                    child: utils.PushButton(icon: Icons.copy, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.edit(profile: _profile, currentUserId: state.getUser()!.id)))),
                  ),
                ],
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
                                  spreadRadius: 5,
                                  offset: const Offset(5, 5),
                                  blurRadius: 10
                              )
                            ]
                        ),
                        child: ListView(
                          children: [
                            Center(
                              child: Column(
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
                                              controller: _titleController..text = _profile.title,
                                              readOnly: true,
                                            )
                                          ),
                                      ),
                                    ),
                                  ),
                                  ///Image container
                                  Padding(
                                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                                      child: SizedBox.square(
                                        dimension: sqrt(MediaQuery.of(context).size.width + MediaQuery.of(context).size.height) * 8,
                                        child: FutureBuilder<String>(
                                          future: FileService().getProfileImage(_profile.id, _profile.image),
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
                                                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0),
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
                                  Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                    child: Container(
                                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 3.4),
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
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Текст",
                                                    hintStyle: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyText1!.color,
                                                    )
                                                ),
                                                controller: _textController..text = text,
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                  ///Chat block
                                  _profile.chatId != "none" ? FutureBuilder<Chat>(
                                      future: ChatService().getChat(_profile.chatId),
                                      builder: (context, snapshot) {
                                        if(!snapshot.hasData) {
                                          return Container();
                                        } else if(snapshot.hasError) {
                                          utils.Toasts.showInfo(context: context, infoMessage: "Ошибка получения данных");
                                          return Container();
                                        } else {
                                          Chat _chat = snapshot.data!;
                                          return Container (
                                            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.4),
                                            child: SizedBox(
                                              width: MediaQuery.of(context).size.width / 1.25,
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
                                                    Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 5, top: 5),
                                                          child: Text("Анкета для чата",
                                                            style: Theme.of(context).textTheme.headline2,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 5, top: 10),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              ChatBlock(chat: _chat),
                                                              if(_chat.organizerId == state.getUser()!.id && _profile.approvementState == ApprovementStates.awaiting.value) ...[
                                                                Padding(
                                                                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 12),
                                                                  child: Column(
                                                                    children: [
                                                                      ElevatedButton(
                                                                          style: ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                                                                          ),
                                                                          onPressed: () async {
                                                                            Profile profile = await ProfileService().getProfile(_profile.id);
                                                                            profile.approvementState = ApprovementStates.approved.value;
                                                                            ProfileService().updateProfile(profile);
                                                                            List list = List.of(_chat.approvedProfiles!);
                                                                            list.add(profile.id);
                                                                            ChatService().addApprovedProfiles(_chat.id, list);
                                                                            NotificationsService(profile.userId).successApprovementNotification(_chat.title, _chat.id);
                                                                            setState(() {
                                                                              _profile = profile;
                                                                              utils.Toasts.showInfo(context: context, infoMessage: "Анкета пользлвателя одобрена", isSuccess: true);
                                                                            });
                                                                          },
                                                                          child: Text(
                                                                            "Одобрить анкету",
                                                                            style: TextStyle(
                                                                                color: Theme.of(context).textTheme.bodyText2!.color,
                                                                                fontStyle: Theme.of(context).textTheme.subtitle2!.fontStyle
                                                                            ),
                                                                          )
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 5),
                                                                        child: ElevatedButton(
                                                                            style: ButtonStyle(
                                                                                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)
                                                                            ),
                                                                            onPressed: () async {
                                                                              Profile profile = await ProfileService().getProfile(_profile.id);
                                                                              profile.approvementState == ApprovementStates.notApproved.value;
                                                                              ProfileService().updateProfile(profile);
                                                                              NotificationsService(_profile.userId).failureApprovementNotification(_chat.title, _chat.id);
                                                                            },
                                                                            child: Text(
                                                                              "Отклонить анкету",
                                                                              style: TextStyle(
                                                                                  color: Theme.of(context).textTheme.bodyText2!.color,
                                                                                  fontStyle: Theme.of(context).textTheme.subtitle2!.fontStyle
                                                                              ),
                                                                            )
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ]
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                  ) : Container()
                                ],
                              ),
                            ),
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
        return AuthScreen();
      },
    );
  }
}
