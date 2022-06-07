import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/custom_user_model.dart';
import 'package:roleplaying_app/src/models/message.dart';
import 'package:roleplaying_app/src/models/rolePlayQueue.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/chat_text_formatter.dart';
import 'package:roleplaying_app/src/services/custom_user_service.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/services/message_service.dart';
import 'package:roleplaying_app/src/services/role_play_queue_service.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat/chat_description_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart';

late Chat? _chat;

class ChatScreen extends StatefulWidget {
  final Chat? chat;
  ChatScreen({Key? key, required this.chat}) : super(key: key) {
    _chat = chat;
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController scrollController = ScrollController();
  bool firstAutoscrollExecuted = false;
  bool shouldAutoscroll = true;
  var menuPozKey = RectGetter.createGlobalKey();
  final TextEditingController _textController = TextEditingController();
  final MessageService messageService = MessageService(_chat!.id);
  bool isQueueCreate = true;
  String? queueId;
  bool isContextMenuOpen = false;
  bool isQueueMenuOpen = false;
  bool isQueueCreateMenuOpen = false;
  late OverlayEntry contextMenuOverlayEntry;
  late OverlayEntry queueMenuOverlayEntry;
  late OverlayEntry queueCreateOverlayEntry;
  late OverlayEntry profileChoseMenu;
  List _chosenUsersId = [];

  openContextMenu() {
    isContextMenuOpen = true;
    contextMenuOverlayEntry = createContextMenuOverlay();
    Overlay.of(context)!.insert(contextMenuOverlayEntry);
  }

  closeContextMenu() {
    isContextMenuOpen = false;
    contextMenuOverlayEntry.remove();
  }

  openQueueMenu() {
    isQueueMenuOpen = true;
    queueMenuOverlayEntry = createQueueMenuOverlay();
    Overlay.of(context)!.insert(queueMenuOverlayEntry);
  }

  closeQueueMenu() {
    isQueueMenuOpen = false;
    queueMenuOverlayEntry.remove();
  }

  openQueueCreateMenu() {
    isQueueCreateMenuOpen = true;
    queueCreateOverlayEntry = createQueueCreateMenuOverlay();
    Overlay.of(context)!.insert(queueCreateOverlayEntry);
  }

  closeQueueCreateMenu() {
    isQueueCreateMenuOpen = false;
    queueCreateOverlayEntry.remove();
  }

  scrollToBottom() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  void scrollListener() {
    firstAutoscrollExecuted = true;

    if (scrollController.hasClients && scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      shouldAutoscroll = true;
    } else {
      shouldAutoscroll = false;
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState> (
        builder: (context, state) {
          if (state is AuthStateAuthenticated && _chat!.usersId.contains(state.getUser()!.id)) {
            return KeyboardDismissOnTap(
              child: WillPopScope(
                onWillPop: () async {
                  if (isContextMenuOpen) {
                    closeContextMenu();
                    return false;
                  } if (isQueueMenuOpen) {
                    closeQueueMenu();
                    return false;
                  } if (isQueueCreateMenuOpen) {
                    closeQueueCreateMenu();
                    return false;
                  }
                  return true;
                },
                child: Scaffold(
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
                        left: 16,
                        top: 15,
                        child: utils.BackButton()
                      ),
                      Positioned(
                        right: 16,
                        top: 15,
                        child: FutureBuilder<Chat>(
                            future: ChatService().getChat(_chat!.id),
                            builder: (context, snapshot) {
                              if(!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              } else {
                                Chat chat = snapshot.data!;
                                chat.id = _chat!.id;
                                return utils.PushButton(icon: Icons.menu, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDescriptionScreen(chat: chat))));
                              }
                            }
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                        child: Center(
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
                              child: Stack(
                                children: [
                                  ListView(
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Column(
                                            children: [
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width / 1.1 - 15,
                                                    height: MediaQuery.of(context).size.height / 1.45,
                                                    child: Stack(
                                                      children: [
                                                        StreamBuilder<List<Message>>(
                                                          stream: messageService.readMessages(),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasError) {
                                                              return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
                                                            }
                                                            if (snapshot.hasData) {
                                                              final messages = snapshot.data!;
                                                              if (scrollController.hasClients && shouldAutoscroll) {
                                                                scrollToBottom();
                                                              }
                                                              if (!firstAutoscrollExecuted && scrollController.hasClients) {
                                                                scrollToBottom();
                                                              }
                                                              if(snapshot.data!.isNotEmpty) {
                                                                return Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                  children: [
                                                                    Flexible(
                                                                      fit: FlexFit.loose,
                                                                      child: ListView.separated(
                                                                        reverse: true,
                                                                        controller: scrollController,
                                                                        scrollDirection: Axis.vertical,
                                                                        itemCount: messages.length,
                                                                        itemBuilder: (BuildContext context, int index) {
                                                                          if (state.getUser()!.id == messages[index].authorId) {
                                                                            return Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                CurUserMessageBox(text: messages[index].text, userId: messages[index].authorId, currentUserId: state.getUser()!.id),
                                                                              ],
                                                                            );
                                                                          } else {
                                                                            return Padding(
                                                                              padding: const EdgeInsets.only(right: 15),
                                                                              child: MessageBox(text: messages[index].text, userId: messages[index].authorId, currentUserId: state.getUser()!.id),
                                                                            );
                                                                          }
                                                                        },
                                                                        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                                                                      ),
                                                                    )
                                                                  ],
                                                                );
                                                              } else {
                                                                return Center(
                                                                  child: Text(
                                                                      "Здесь пока пусто",
                                                                      style: TextStyle(
                                                                        color: Theme.of(context).textTheme.subtitle1!.color!.withOpacity(0.6),
                                                                        fontStyle: Theme.of(context).textTheme.bodyText1!.fontStyle,
                                                                        fontSize: 24
                                                                      )
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                            return const CircularProgressIndicator();
                                                          },
                                                        )
                                                      ],
                                                    )
                                                  )
                                                ],
                                              ),
                                              Center(
                                                child: Padding(
                                                    padding: EdgeInsets.only(top: 5, left: MediaQuery.of(context).size.width / 90),
                                                    child: Row(
                                                      children: [
                                                        RectGetter(
                                                          key: menuPozKey,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                                              shape: MaterialStateProperty.all(const CircleBorder()),
                                                              padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                                                            ),
                                                            child: Icon(Icons.menu_rounded,
                                                                color: Colors.white,
                                                                size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width))),
                                                            onPressed: () {
                                                              openContextMenu();
                                                            },
                                                          ),
                                                        ),
                                                        Flexible(
                                                            child: Container(
                                                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 4.5),
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
                                                                      borderRadius: const BorderRadius.all(
                                                                        Radius.circular(20.0),
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
                                                                    padding: const EdgeInsets.only(left: 10),
                                                                    child: TextField(
                                                                        style: TextStyle(
                                                                            color: Theme.of(context).textTheme.bodyText1!.color!
                                                                        ),
                                                                        textAlign: TextAlign.left,
                                                                        maxLines: null,
                                                                        controller: _textController,
                                                                        decoration: InputDecoration(
                                                                            border: InputBorder.none,
                                                                            hintText: "Сообщение",
                                                                            hintStyle: TextStyle(
                                                                                color: Theme.of(context).textTheme.bodyText2?.color
                                                                            )
                                                                        )
                                                                    ),
                                                                  )
                                                              ),
                                                            )
                                                        ),
                                                        ElevatedButton(
                                                          style: ButtonStyle(
                                                            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                                            shape: MaterialStateProperty.all(const CircleBorder()),
                                                            padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                                                          ),
                                                          child: Icon(Icons.arrow_forward_ios_rounded,
                                                              color: Colors.white,
                                                              size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width))),
                                                          onPressed: () async {
                                                            if (_textController.text.trim().isEmpty) {
                                                              Fluttertoast.showToast(
                                                                  msg: "Введите сообщение",
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 3,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 16.0
                                                              );
                                                              return;
                                                            }
                                                            final nextPlayerWord = RegExp(r' !next', caseSensitive: false);
                                                            if (_textController.text.trim().contains(nextPlayerWord)) {
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) => SimpleDialog(
                                                                    title: Text("Выберите очередь вашего текущего персонажа"),
                                                                    children: [
                                                                      FutureBuilder<List<RolePlayQueue>>(
                                                                          future: RolePlayQueueService(_chat!).getQueueByUserId(state.getUser()!.id),
                                                                          builder: (context, snapshot) {
                                                                            if(!snapshot.hasData) {
                                                                              return const CircularProgressIndicator();
                                                                            } else if(snapshot.hasError) {
                                                                              return utils.Toasts.showErrorMessage(errorMessage: "Ошибка получения очередей");
                                                                            } else {
                                                                              final queues = snapshot.data!;
                                                                              return ListView.separated(
                                                                                shrinkWrap: true,
                                                                                scrollDirection: Axis.vertical,
                                                                                itemCount: queues.length,
                                                                                separatorBuilder: (BuildContext context, int index) => const Divider(),
                                                                                itemBuilder: (BuildContext context, int index) {
                                                                                  final queue = queues[index];
                                                                                  final _height = MediaQuery.of(context).size.height / 2.5;
                                                                                  final _width = MediaQuery.of(context).size.width / 2;
                                                                                  return Row(
                                                                                    children: [
                                                                                      Flexible(
                                                                                        child: GestureDetector(
                                                                                          onTap: () {
                                                                                            List list = List.of(queue.users);
                                                                                            if(list.first == state.getUser()!.id) {
                                                                                              list.remove(state.getUser()!.id);
                                                                                              list.add(state.getUser()!.id);
                                                                                              queue.users = list;
                                                                                              RolePlayQueueService(_chat!).updateQueue(queue);
                                                                                              ChatTextFormatter(
                                                                                                  nextPlayerId: list.first,
                                                                                                  chatId: _chat!.id,
                                                                                                  chatName: _chat!.title,
                                                                                                  text: _textController.text.trim()
                                                                                              ).nextPlayerNotifier();
                                                                                            }
                                                                                            String _text = _textController.text;
                                                                                            Message _message = Message(
                                                                                                authorId: state.getUser()!.id,
                                                                                                text: _text
                                                                                            );
                                                                                            messageService.addMessage(_message);
                                                                                            _textController.clear();
                                                                                            _textController.clear();
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Container(
                                                                                            constraints: BoxConstraints(maxHeight: _height / 3, maxWidth: _width - 10),
                                                                                            decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(15),
                                                                                                border: Border.all(color: Theme.of(context).primaryColor, width: 1)
                                                                                            ),
                                                                                            child: ListView.separated(
                                                                                              scrollDirection: Axis.horizontal,
                                                                                              itemCount: queue.users.length,
                                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                                return FutureBuilder<CustomUserModel>(
                                                                                                    future: CustomUserService().getUser(queue.users[index]),
                                                                                                    builder: (context, snapshot2) {
                                                                                                      if (!snapshot2.hasData){
                                                                                                        return const CircularProgressIndicator();
                                                                                                      } else if (snapshot2.hasError) {
                                                                                                        return utils.ErrorCatcher(snapshot: snapshot2, showErrorTextWidget: true);
                                                                                                      }
                                                                                                      return Container(
                                                                                                        constraints: BoxConstraints(maxHeight: sqrt(MediaQuery.of(context).size.height) * 3, maxWidth: sqrt(MediaQuery.of(context).size.width) * 4),
                                                                                                        child: Column(
                                                                                                          children: [
                                                                                                            utils.CustomCircleIconButton(
                                                                                                                onPressed: null,
                                                                                                                scale: 1.2,
                                                                                                                borderWidth: 2,
                                                                                                                future: FileService().getUserImage(snapshot2.data!.idUser, snapshot2.data!.image)
                                                                                                            ),
                                                                                                            Text(
                                                                                                              snapshot2.data!.nickName,
                                                                                                              maxLines: 1,
                                                                                                              textAlign: TextAlign.center,
                                                                                                              style: Theme.of(context).textTheme.subtitle2,
                                                                                                              overflow: TextOverflow.ellipsis,
                                                                                                              textScaleFactor: 0.6,
                                                                                                            )
                                                                                                          ],
                                                                                                        ),
                                                                                                      );
                                                                                                    }
                                                                                                );
                                                                                              },
                                                                                              separatorBuilder: (BuildContext context, int index) { return const Divider(); },
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                          }
                                                                      )
                                                                    ],
                                                                  )
                                                              );
                                                            } else {
                                                              String _text = _textController.text;
                                                              Message _message = Message(
                                                                  authorId: state.getUser()!.id,
                                                                  text: _text
                                                              );
                                                              messageService.addMessage(_message);
                                                              _textController.clear();
                                                            }
                                                          },
                                                        )
                                                      ],
                                                    )
                                                ),
                                              )
                                            ],
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
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          else if (state is AuthStateAuthenticated && !_chat!.usersId.contains(state.getUser()!.id)) {
            return Scaffold(
              body: Stack(
                children: [
                  const Positioned(
                    left: 15,
                    top: 15,
                    child: utils.BackButton()
                  ),
                  Center(
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
                          padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Вы ещё не вступили в чат",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                                            spreadRadius: 5,
                                            offset: const Offset(5, 5),
                                            blurRadius: 10
                                        )
                                      ]
                                  ),
                                  child: TextButton(
                                    child: Text("Вступить",
                                        style: Theme.of(context).textTheme.bodyText1
                                    ),
                                    onPressed: () async {
                                      await ChatService().addNewUserInChat(_chat!, state.getUser()!.id);
                                      _chat!.usersId.add(state.getUser()!.id);
                                      setState(() {
                                        ChatScreen(chat: _chat);
                                      });
                                    },
                                  )
                              )
                            ],
                          ),
                        )
                      ),
                    ),
                  )
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

  OverlayEntry createQueueCreateMenuOverlay() {
    return OverlayEntry(builder: (context) {
      double _height = MediaQuery.of(context).size.height / 2;
      double _width = MediaQuery.of(context).size.width / 1.5;
      return WillPopScope(
        onWillPop: () async {
          closeQueueCreateMenu();
          return false;
        },
        child: GestureDetector(
            onTap: () {
              isQueueCreate = true;
              _chosenUsersId.clear();
              closeQueueCreateMenu();
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0x41000000),
                child: Center(
                  child: GestureDetector(
                    onTap: () { },
                    child: Container(
                        constraints: BoxConstraints(maxHeight: _height + 5, maxWidth: _width),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).cardColor.withOpacity(0.2),
                                  spreadRadius: 5,
                                  offset: const Offset(5, 5),
                                  blurRadius: 10
                              )
                            ]
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ///List of chosen users
                                  Expanded(
                                    child: Container(
                                      constraints: BoxConstraints(maxHeight: _height / 3 - 5),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _chosenUsersId.isEmpty ? 0 : _chosenUsersId.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return FutureBuilder<CustomUserModel>(
                                              future: CustomUserService().getUser(_chosenUsersId[index]),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  return utils.ErrorCatcher(snapshot: snapshot);
                                                } else {
                                                  CustomUserModel _user = snapshot.data!;
                                                  return Container(
                                                    constraints: BoxConstraints(maxHeight: _height / 4, maxWidth: sqrt(MediaQuery.of(context).size.width) * 4),
                                                    child: Column(
                                                      children: [
                                                        utils.CustomCircleIconButton(
                                                            onPressed: () {
                                                              _chosenUsersId.remove(_chosenUsersId[index]);
                                                              return setState(() {
                                                                closeQueueCreateMenu();
                                                                openQueueCreateMenu();
                                                              });
                                                            },
                                                            scale: 2,
                                                            borderWidth: 2,
                                                            future: FileService().getUserImage(_user.idUser, _user.image)
                                                        ),
                                                        Text(
                                                          _user.nickName,
                                                          style: Theme.of(context).textTheme.subtitle2,
                                                          maxLines: 1,
                                                          textAlign: TextAlign.center,
                                                          overflow: TextOverflow.ellipsis,
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }
                                              }
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  ///List of users in chat
                                  Expanded(
                                    child: Container(
                                        constraints: BoxConstraints(maxHeight: _height / 3),
                                        child: FutureBuilder<Chat>(
                                          future: ChatService().getChat(_chat!.id),
                                          builder: (context, snapshot1) {
                                            if (snapshot1.hasError) {
                                              return utils.ErrorCatcher(
                                                  snapshot: snapshot1,
                                                  showErrorTextWidget: true
                                              );
                                            } else if(!snapshot1.hasData) {
                                              return const CircularProgressIndicator();
                                            } else {
                                              Chat chat = snapshot1.data!;
                                              return Column(
                                                children: [
                                                  Text("Выберите полльзователя(-ей)", style: TextStyle(color: Theme.of(context).textTheme.subtitle1!.color, fontSize: 10)),
                                                  Container(
                                                    constraints: BoxConstraints(maxHeight: _height / 3),
                                                    child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        shrinkWrap: true,
                                                        itemCount: chat.usersId.length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          String userId = chat.usersId[index];
                                                          return FutureBuilder<CustomUserModel>(
                                                              future: CustomUserService().getUser(userId),
                                                              builder: (context, snapshot2) {
                                                                if (!snapshot2.hasData) {
                                                                  return const CircularProgressIndicator();
                                                                } else if (snapshot2.hasError) {
                                                                  return utils.ErrorCatcher(snapshot: snapshot2);
                                                                } else {
                                                                  CustomUserModel _user = snapshot2.data!;
                                                                  return Container(
                                                                    constraints: BoxConstraints(maxHeight: _height / 4, maxWidth: sqrt(MediaQuery.of(context).size.width) * 4),
                                                                    child: Column(
                                                                      children: [
                                                                        utils.CustomCircleIconButton(
                                                                          future: FileService().getUserImage(_user.idUser, _user.image),
                                                                          scale: 2,
                                                                          borderWidth: 2,
                                                                          onPressed: () {
                                                                            if (_chosenUsersId.contains(userId)) {
                                                                              Toasts.showInfo(context: context, infoMessage: "Этот пользователь уже добавлен в очередь");
                                                                              return;
                                                                            }
                                                                            _chosenUsersId.add(userId);
                                                                            return setState(() {
                                                                              closeQueueCreateMenu();
                                                                              openQueueCreateMenu();
                                                                            });
                                                                          },
                                                                        ),
                                                                        Text(
                                                                          _user.nickName,
                                                                          style: Theme.of(context).textTheme.subtitle2,
                                                                          maxLines: 1,
                                                                          textAlign: TextAlign.center,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                          );
                                                        }
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        )
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width / 2,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15.0),
                                                )
                                            )
                                        ),
                                        onPressed: () {
                                          RolePlayQueue queue = RolePlayQueue(
                                              users: List.of(_chosenUsersId)
                                          );
                                          if (isQueueCreate) {
                                            if (queue.users.isEmpty) {
                                              utils.Toasts.showInfo(context: context, infoMessage: 'Добавьте участников');
                                              return;
                                            }
                                            RolePlayQueueService(_chat!).addQueue(queue);
                                          } else {
                                            isQueueCreate = true;
                                            queue.id = queueId!;
                                            if (_chosenUsersId.isEmpty) {
                                              RolePlayQueueService(_chat!).deleteQueue(queue);
                                            } else {
                                              RolePlayQueueService(_chat!).updateQueue(queue);
                                            }
                                          }
                                          _chosenUsersId.clear();
                                          closeQueueCreateMenu();
                                        },
                                        child: Text("Сохранить", style: Theme.of(context).textTheme.bodyText1)
                                    ),
                                  )
                                ],
                              ),
                            )
                        )
                    ),
                  ),
                ),
              ),
            )
        ),
      );
    });
  }

  OverlayEntry createQueueMenuOverlay() {
    return OverlayEntry(builder: (context) {
      final _height = MediaQuery.of(context).size.height / 2.5;
      final _width = MediaQuery.of(context).size.width / 2;
      return WillPopScope(
        onWillPop: () async {
          closeQueueMenu();
          return false;
        },
        child: GestureDetector(
            onTap: closeQueueMenu,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: const Color(0x41000000),
                child: Center(
                  child: GestureDetector(
                    onTap: () { },
                    child: Container(
                        constraints: BoxConstraints(maxHeight: _height, maxWidth: _width),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).cardColor.withOpacity(0.2),
                                  spreadRadius: 5,
                                  offset: const Offset(5, 5),
                                  blurRadius: 10
                              )
                            ]
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StreamBuilder<List<RolePlayQueue>>(
                                    stream: RolePlayQueueService(_chat!).readQueues(),
                                    builder: (context, snapshot1) {
                                      if(snapshot1.hasError) {
                                        return utils.ErrorCatcher(snapshot: snapshot1, showErrorTextWidget: true);
                                      } else if (!snapshot1.hasData) {
                                        return const CircularProgressIndicator();
                                      }
                                      final queues = snapshot1.data!;
                                      return GestureDetector(
                                        onLongPress: () { },
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Column(
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(maxHeight: _height / 1.35),
                                                child: ListView.separated(
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.vertical,
                                                  itemCount: queues.length,
                                                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                                                  itemBuilder: (BuildContext context, int index) {
                                                    final queue = queues[index];
                                                    return Row(
                                                      children: [
                                                        Flexible(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              _chosenUsersId.clear();
                                                              _chosenUsersId = List.from(queue.users);
                                                              isQueueCreate = false;
                                                              queueId = queue.id;
                                                              closeQueueMenu();
                                                              openQueueCreateMenu();
                                                            },
                                                            child: Container(
                                                              constraints: BoxConstraints(maxHeight: _height / 3, maxWidth: _width - 10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(15),
                                                                  border: Border.all(color: Theme.of(context).primaryColor, width: 1)
                                                              ),
                                                              child: ListView.separated(
                                                                scrollDirection: Axis.horizontal,
                                                                itemCount: queue.users.length,
                                                                itemBuilder: (BuildContext context, int index) {
                                                                  return FutureBuilder<CustomUserModel>(
                                                                      future: CustomUserService().getUser(queue.users[index]),
                                                                      builder: (context, snapshot2) {
                                                                        if (!snapshot2.hasData){
                                                                          return const CircularProgressIndicator();
                                                                        } else if (snapshot2.hasError) {
                                                                          return utils.ErrorCatcher(snapshot: snapshot2, showErrorTextWidget: true);
                                                                        }
                                                                        return Container(
                                                                          constraints: BoxConstraints(maxHeight: sqrt(MediaQuery.of(context).size.height) * 3, maxWidth: sqrt(MediaQuery.of(context).size.width) * 4),
                                                                          child: Column(
                                                                            children: [
                                                                              utils.CustomCircleIconButton(
                                                                                  onPressed: null,
                                                                                  scale: 1.2,
                                                                                  borderWidth: 2,
                                                                                  future: FileService().getUserImage(snapshot2.data!.idUser, snapshot2.data!.image)
                                                                              ),
                                                                              Text(
                                                                                snapshot2.data!.nickName,
                                                                                maxLines: 1,
                                                                                textAlign: TextAlign.center,
                                                                                style: Theme.of(context).textTheme.subtitle2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                textScaleFactor: 0.6,
                                                                              )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) { return const Divider(); },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            )
                                        )
                                    ),
                                    onPressed: () {
                                      closeQueueMenu();
                                      openQueueCreateMenu();
                                    },
                                    child: const Icon(Icons.add, color: Colors.black),
                                  ),
                                )
                              ],
                            )
                        )
                    ),
                  ),
                ),
              ),
            )
        ),
      );
    });
  }

  OverlayEntry createContextMenuOverlay() {
    Rect rect = RectGetter.getRectFromKey(menuPozKey)!;
    return OverlayEntry(builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          closeContextMenu();
          return false;
        },
        child: GestureDetector(
            onTap: closeContextMenu,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Positioned(
                      left: rect.left,
                      top: rect.top - rect.height,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(width: 0.5),
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context).cardColor.withOpacity(0.2),
                                    spreadRadius: 5,
                                    offset: const Offset(5, 5),
                                    blurRadius: 10
                                )
                              ]
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: IntrinsicWidth(
                                child: Column(
                                  children: [
                                    TextButton(
                                      child: Text("Очерёдность", style: Theme.of(context).textTheme.subtitle1),
                                      onPressed: () {
                                        closeContextMenu();
                                        openQueueMenu();
                                      },
                                    ),
                                  ],
                                ),
                              )
                          )
                      ),
                    ),
                  ],
                ),
              ),
            )
        ),
      );
    });
  }
}

///Message box of logged user
class CurUserMessageBox extends StatelessWidget {
  final String text;
  final String userId;
  final String currentUserId;

  const CurUserMessageBox({Key? key, required this.text, required this.userId, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.2),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                        spreadRadius: 2,
                        offset: const Offset(5, 5),
                        blurRadius: 10
                    )
                  ]
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 5, right: MediaQuery.of(context).size.width / 5, bottom: 20),
                    child: Column(
                      children: [
                        AuthorOfMessage(userId: userId, currentUserId: currentUserId),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(text,
                            style: TextStyle(
                                color: Theme.of(context).textTheme.subtitle2!.color,
                                fontStyle: Theme.of(context).textTheme.bodyText1!.fontStyle
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 3,
                    child: FutureBuilder<CustomUserModel>(
                        future: CustomUserService().getUser(userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData){
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return utils.CustomCircleIconButton(
                              future: FileService().getUserImage(snapshot.data!.idUser, snapshot.data!.image),
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfileScreen(user: snapshot.data!))),
                              scale: 1.5,
                              borderWidth: 2,
                              borderColor: Theme.of(context).colorScheme.secondaryContainer,
                            );
                          }
                        }
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///Message box
class MessageBox extends StatelessWidget {
  final String text;
  final String userId;
  final String currentUserId;

  const MessageBox({Key? key, required this.text, required this.userId, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Stack(
                  children: [
                    FutureBuilder<CustomUserModel>(
                        future: CustomUserService().getUser(userId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData){
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return utils.CustomCircleIconButton(
                              future: FileService().getUserImage(snapshot.data!.idUser, snapshot.data!.image),
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfileScreen(user: snapshot.data!))),
                              borderWidth: 2,
                              scale: 1.5,
                            );
                          }
                        }
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 5, top: 5, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthorOfMessage(userId: userId, currentUserId: currentUserId),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(text,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.subtitle2!.color,
                                  fontStyle: Theme.of(context).textTheme.bodyText1!.fontStyle
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}

///Getting message author
class AuthorOfMessage extends StatelessWidget {
  final String userId;
  final String currentUserId;

  const AuthorOfMessage({Key? key, required this.userId, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomUserModel>(
        future: CustomUserService().getUser(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text("Загрузка", style: Theme.of(context).textTheme.subtitle1),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle1),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text(
                  snapshot.data!.nickName.toString(),
                  style: TextStyle(
                    color: snapshot.data!.idUser == currentUserId ? Theme.of(context).textTheme.subtitle1!.color : Theme.of(context).textTheme.subtitle2!.color,
                    fontStyle: Theme.of(context).textTheme.subtitle2!.fontStyle,
                    fontSize: 14
                  ),
                  overflow: TextOverflow.fade
              ),
            );
          }
        }
    );
  }
}