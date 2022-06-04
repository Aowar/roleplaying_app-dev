import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/custom_user_model.dart';
import 'package:roleplaying_app/src/services/custom_user_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;

class ChatUsersGridViewScreen extends StatelessWidget {
  final String chatId;

  const ChatUsersGridViewScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if(state is AuthStateAuthenticated) {
            return ChatUsersGridView(chatId: chatId);
          } else {
            return AuthScreen();
          }
        });
  }
}

class ChatUsersGridView extends StatefulWidget {
  final String chatId;

  const ChatUsersGridView({Key? key, required this.chatId}) : super(key: key);

  @override
  State<ChatUsersGridView> createState() => _ChatUsersGridViewState();
}

class _ChatUsersGridViewState extends State<ChatUsersGridView> {

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
                    child: StreamBuilder<List<CustomUserModel>>(
                        stream: CustomUserService().readUsersInChat(widget.chatId),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            utils.Toasts.showInfo(context: context, infoMessage: "Ошибка загрузки данных");
                            return Container();
                          } else {
                            List<CustomUserModel> usersList = snapshot.data!;
                            return Padding(
                                padding: const EdgeInsets.all(5),
                                child: GridView.builder(
                                    itemCount: usersList.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                    ),
                                    itemBuilder: (BuildContext context, int index) {
                                      CustomUserModel user = usersList[index];
                                      return utils.CustomCircleIconButton(
                                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(user: user))),
                                          scale: 2,
                                          borderWidth: 2,
                                          future: FileService().getUserImage(user.idUser, user.image)
                                      );
                                    }
                                )
                            );
                          }
                        }
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

