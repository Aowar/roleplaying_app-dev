import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/notifications/notifications.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/notifications_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat/chat_screen.dart';
import 'package:roleplaying_app/src/ui/profile/profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:rxdart/rxdart.dart';

class NotificationsScreen extends StatelessWidget {

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateAuthenticated) {
            return NotificationsView(userId: state.getUser()!.id, state: state);
          } else {
            return AuthScreen();
          }
        }
    );
  }
}

class NotificationsView extends StatefulWidget {
  final String userId;
  final AuthState state;

  const NotificationsView({Key? key, required this.userId, required this.state}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool isLoading = false;

  getIcon(String typeOfNotification) {
    switch(typeOfNotification) {
      case "chat_notification":
        return Icons.chat;
      case "profile_notification":
        return Icons.library_books_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: utils.BackButton()
          ),
          Positioned(
              top: 16,
              right: 16,
              child: utils.PushButton(
                icon: Icons.clear_all,
                backgroundColor: const Color(0xff920000),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: ListTile(
                          title: Text(
                              "Очистить уведомления",
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.headline2!.color,
                                  fontSize: 18
                              )
                          ),
                        ),
                        actions: <Widget>[
                          Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    NotificationsService(widget.userId).deleteAllNotifications();
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
              )
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 8),
            child: Center(
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
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: StreamBuilder<List<Notifications>>(
                            stream: NotificationsService(widget.state.getUser()!.id).readNotifications(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
                              }
                              if (snapshot.hasData) {
                                List<Notifications> notificationsList = snapshot.data!;
                                if(notificationsList.isEmpty) {
                                  return Center(
                                    child: Text(
                                        "Пусто",
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.headline2!.color!.withOpacity(0.5),
                                            fontSize: Theme.of(context).textTheme.headline2!.fontSize
                                        )
                                    )
                                  );
                                } else {
                                  return ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    itemCount: notificationsList.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      Notifications notification = notificationsList[index];
                                      return Row(
                                        children: [
                                          Container(
                                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.35),
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                                  borderRadius: BorderRadius.circular(15)
                                              ),
                                              child: ListTile(
                                                  title: Text(notification.title, style: Theme.of(context).textTheme.headline2),
                                                  subtitle: Text(notification.text, style: Theme.of(context).textTheme.subtitle1),
                                                  trailing: Icon(getIcon(notification.type)),
                                                  onTap: isLoading ? null :
                                                      () async {
                                                    isLoading = true;
                                                    setState(() { });
                                                    if(notification.type == NotificationType.chat.value) {
                                                      Chat _chat;
                                                      try {
                                                        _chat = await ChatService().getChat(notification.navigationId);
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat: _chat)));
                                                      } catch(e) {
                                                        isLoading = false;
                                                        utils.Toasts.showErrorMessage(errorMessage: "Неизвестная ошибка, возможно этого чата не существует");
                                                        return;
                                                      }
                                                    } else {
                                                      try {
                                                        Profile _profile = await ProfileService().getProfile(notification.navigationId);
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: _profile)));
                                                      } catch(e) {
                                                        isLoading = false;
                                                        utils.Toasts.showErrorMessage(errorMessage: "Неизвестная ошибка, возможно этой анкеты не существует");
                                                        return;
                                                      }
                                                    }
                                                  }
                                              )
                                          ),
                                          IconButton(
                                              onPressed: () => NotificationsService(widget.userId).deleteNotification(notification.id),
                                              icon: const Icon(Icons.clear, color: Colors.red)
                                          )
                                        ],
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                                  );
                                }
                              }
                              return const CircularProgressIndicator();
                            }
                        )
                    ),
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }
}