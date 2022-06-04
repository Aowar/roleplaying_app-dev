import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/notifications_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/blocks_builder.dart';

class ApprovingScreen extends StatelessWidget {
  final String chatId;
  const ApprovingScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if(state is AuthStateAuthenticated) {
          return ApprovingView(chatId: chatId, userId: state.getUser()!.id);
        } else {
          return AuthScreen();
        }
      }
    );
  }
}

class ApprovingView extends StatefulWidget {
  final String chatId;
  final String userId;
  const ApprovingView({Key? key, required this.chatId, required this.userId}) : super(key: key);

  @override
  State<ApprovingView> createState() => _ApprovingViewState();
}

class _ApprovingViewState extends State<ApprovingView> {
  bool isDataEmpty = true;
  late List approvedProfiles;

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
                icon: Icons.check,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: isDataEmpty ? null : () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: ListTile(
                          title: Text(
                              "Принять все анкеты?",
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
                                    ProfileService().approveListOfProfiles(widget.chatId, approvedProfiles);
                                    ChatService().addApprovedProfiles(widget.chatId, approvedProfiles);
                                    NotificationsService(widget.userId).deleteNotificationsByNavId(approvedProfiles);
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
                        child: StreamBuilder<List<Profile>>(
                            stream: ProfileService().readAwaitingApproveProfiles(widget.chatId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
                              }
                              if (snapshot.hasData) {
                                isDataEmpty = false;
                                List<Profile> profilesList = snapshot.data!;
                                if(profilesList.isEmpty) {
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
                                  return GridView.builder(
                                      itemCount: profilesList.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                    ),
                                    itemBuilder: (BuildContext context, int index) {
                                      Profile profile = profilesList[index];
                                      return ProfileBlock(profile: profile);
                                    }
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

