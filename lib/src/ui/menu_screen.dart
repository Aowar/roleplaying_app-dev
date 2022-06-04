import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/custom_user_model.dart';
import 'package:roleplaying_app/src/models/notifications/notifications.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/custom_user_service.dart';
import 'package:roleplaying_app/src/services/notifications_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat/chat_edit_screen.dart';
import 'package:roleplaying_app/src/ui/chat/chat_screen.dart';
import 'package:roleplaying_app/src/ui/grid_screen/chat_grid_screen.dart';
import 'package:roleplaying_app/src/ui/grid_screen/profile_grid_screen.dart';
import 'package:roleplaying_app/src/ui/grid_screen/user_chats_grid_screen.dart';
import 'package:roleplaying_app/src/ui/notifications_screen.dart';
import 'package:roleplaying_app/src/ui/profile/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/profile/profile_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/fetch_info.dart';

import 'utils/Utils.dart';
import 'utils/fetch_info_from_db/blocks_builder.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateAuthenticated) {
            return MenuView(state: state);
          } else {
            return AuthScreen();
          }
        }
    );
  }
}


class MenuView extends StatefulWidget{
  final AuthState state;

  const MenuView({Key? key, required this.state}) : super(key: key);

  @override
  State<MenuView> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuView> {


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
                  ///user profile button
                  Positioned(
                    left: 16,
                    top: 16,
                    child: FutureBuilder<CustomUserModel>(
                        future: CustomUserService().getUser(state.getUser()!.id),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData){
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text("Error");
                          } else {
                            return PushButton(icon: Icons.account_circle_sharp, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(user: snapshot.data!))));
                          }
                        }
                    ),
                  ),
                  ///notifications button
                  Positioned(
                      right: 16,
                      top: 16,
                      child: StreamBuilder<List<Notifications>>(
                        stream: NotificationsService(state.getUser()!.id).readNotifications(),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData) {
                            return PushButton(
                                icon: Icons.notifications,
                                onPressed: () => Toasts.showInfo(context: context, infoMessage: "Уведомлений нет")
                            );
                          } else if(snapshot.hasError) {
                            Toasts.showErrorMessage(errorMessage: "Ошибка получения уведомлений\n" + snapshot.error.toString());
                            return PushButton(
                                icon: Icons.notifications,
                                onPressed: () {
                                  null;
                                }
                            );
                          } else {
                            if(snapshot.data!.isEmpty){
                              return PushButton(
                                  icon: Icons.notifications,
                                  onPressed: () async {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                                  }
                              );
                            } else {
                              for(Notifications notification in snapshot.data!) {
                                if(!notification.isRead) {
                                  localNotificationService.showNotification(snapshot.data!.last, state.getUser()!.id);
                                }
                              }
                              return ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                    shape: MaterialStateProperty.all(const CircleBorder()),
                                    padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                                  },
                                  child: Stack(
                                    children: [
                                      Center(
                                          child: Icon(Icons.notifications,
                                            color: Colors.white,
                                            size: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                                          )
                                      ),
                                      Positioned(
                                          bottom: 1,
                                          right: 1,
                                          child: SizedBox.square(
                                            dimension: sqrt(MediaQuery.
                                            of(context).size.height + MediaQuery.of(context).size.width) / 3,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle
                                              ),
                                            ),
                                          )
                                      )
                                    ],
                                  )
                              );
                            }
                          }
                        },
                      )
                  ),
                  ///main block
                  Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 7.5),
                      child: Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.1),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ListView(
                                children: [
                                  ///Chats block
                                  GestureDetector(
                                    onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatsGridScreen())),
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
                                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.1),
                                      child: Stack(
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.45),
                                            child: SizedBox(
                                              width: MediaQuery.of(context).size.width / 1.1,
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
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10, top: 2),
                                                      child: Text("Чаты",
                                                        style: Theme.of(context).textTheme.headline2,
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding: const EdgeInsets.only(left: 20, top: 35),
                                                        child: ChatsListStream(stream: ChatService().readChats())
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Positioned(
                                              bottom: 8,
                                              right: 10,
                                              child: Text(
                                                  "Открыть блок",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 12,
                                                    decoration: TextDecoration.underline,
                                                  )
                                              )
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  ///Profiles block
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilesGridScreen(userId: state.getUser()!.id))),
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
                                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.1),
                                        child: Stack(
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.45),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.1,
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
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10, top: 2),
                                                        child: Text("Мои анкеты",
                                                          style: Theme.of(context).textTheme.headline2,
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding: const EdgeInsets.only(left: 20, top: 35),
                                                          child: ProfilesList(userId: state.getUser()!.id)
                                                      ),
                                                      Positioned(
                                                          right: 5,
                                                          top: 5,
                                                          child: PushButton(icon: Icons.add, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.create(currentUserId: state.getUser()!.id))))
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Positioned(
                                                bottom: 8,
                                                right: 10,
                                                child: Text(
                                                    "Открыть блок",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                      decoration: TextDecoration.underline,
                                                    )
                                                )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ///User chats block
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserChatsGridScreen())),
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
                                        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 4.1),
                                        child: Stack(
                                          children: [
                                            Container (
                                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.45),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.1,
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
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10, top: 2),
                                                        child: Text("Мои чаты",
                                                          style: Theme.of(context).textTheme.headline2,
                                                        ),
                                                      ),
                                                      Padding(
                                                          padding: const EdgeInsets.only(left: 20, top: 35),
                                                          child: ChatsListStream(
                                                            stream: ChatService().readUserChats(state.getUser()!.id),
                                                          )
                                                      ),
                                                      Positioned(
                                                          right: 5,
                                                          top: 5,
                                                          child: PushButton(icon: Icons.add, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatEditScreen.create())))
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Positioned(
                                                bottom: 8,
                                                right: 10,
                                                child: Text(
                                                    "Открыть блок",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                      decoration: TextDecoration.underline,
                                                    )
                                                )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      )
                  )
                ],
              ),
            );
          }
          return AuthScreen();
        }
    );
  }

  @override
  void initState() {
    super.initState();
    localNotificationService.init();
    localNotificationService.setOnNotificationClick(onNotificationClick);
  }

  onNotificationClick(String payload) async {
    List strings = payload.split("\n");
    String type = strings.first;
    String id = strings.last;
    switch(type) {
      case "chat_notification":
        Chat chat = await ChatService().getChat(id);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)));
        break;
      case "profile_notification":
        Profile profile = await ProfileService().getProfile(id);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: profile)));
        break;
      case "chat_private_notification":
        Chat chat = await ChatService().getChat(id);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)));
        break;
    }
  }
}

///Getting chats from DB
class ChatsListStream extends StatelessWidget {
  final Stream<List<Chat>> stream;
  const ChatsListStream({Key? key, required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chat>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Toasts.showErrorMessage(errorMessage: snapshot.error.toString());
          return Text("Ошибка получения данных \n" + snapshot.error.toString(), style: Theme.of(context).textTheme.subtitle1);
        }
        if (snapshot.hasData) {
          if(snapshot.data!.isEmpty) {
            return Text("Пусто", style: Theme.of(context).textTheme.subtitle1);
          }
          final chats = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ChatBlock(chat: chats[index]);
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
}