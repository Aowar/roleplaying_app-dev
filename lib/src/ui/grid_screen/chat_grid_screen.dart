import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/blocks_builder.dart';

class ChatsGridScreen extends StatelessWidget {
  const ChatsGridScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if(state is AuthStateAuthenticated) {
            return const ChatsGridView();
          } else {
            return AuthScreen();
          }
        });
  }
}

class ChatsGridView extends StatefulWidget {
  const ChatsGridView({Key? key}) : super(key: key);

  @override
  State<ChatsGridView> createState() => _ChatsGridViewState();
}

class _ChatsGridViewState extends State<ChatsGridView> {

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
                    child: StreamBuilder<List<Chat>>(
                        stream: ChatService().readChats(),
                        builder: (context, snapshot) {
                          if(!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            utils.Toasts.showInfo(context: context, infoMessage: "Ошибка загрузки данных");
                            return Container();
                          } else {
                            List<Chat> chatsList = snapshot.data!;
                            return Padding(
                                padding: const EdgeInsets.all(5),
                                child: GridView.builder(
                                    itemCount: chatsList.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                    ),
                                    itemBuilder: (BuildContext context, int index) {
                                      Chat chat = chatsList[index];
                                      return ChatBlock(chat: chat);
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

