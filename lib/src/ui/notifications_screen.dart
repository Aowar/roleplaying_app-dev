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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateAuthenticated) {
            return NotificationsView(userId: state.getUser()!.id);
          } else {
            return AuthScreen();
          }
        }
    );
  }
}

class NotificationsView extends StatefulWidget {
  final String userId;

  const NotificationsView({Key? key, required this.userId}) : super(key: key);

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
                            stream: NotificationsService(widget.userId).readNotifications(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
                              }
                              if (snapshot.hasData) {
                                List<Notifications> notificationsList = snapshot.data!;
                                return ListView.separated(
                                  scrollDirection: Axis.vertical,
                                  itemCount: notificationsList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    Notifications notification = notificationsList[index];
                                    return Container(
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
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                                );
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