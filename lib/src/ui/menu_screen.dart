import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/services/customUserService.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_edit_screen.dart';
import 'package:roleplaying_app/src/ui/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/fetch_info.dart';

import 'utils/Utils.dart';

class MenuScreen extends StatefulWidget{

  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateAuthenticated) {
            return Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 15,
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
                  Positioned(
                      right: 15,
                      top: 15,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  spreadRadius: 5,
                                  offset: const Offset(5, 5),
                                  blurRadius: 10
                              )
                            ]
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          color: Colors.white,
                          iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                          onPressed: () {
                            _authService.logOut();
                            authBloc.add(const UserLoggedOut());
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthScreen()), (route) => false);
                          },
                        ),
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4.5),
                      child: Center(
                        child: Column(
                          children: [
                            ///Chats block
                            Container (
                              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.7),
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
                                          child: FetchInfoFromDb.itemOfChatsList()
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ///Profiles block
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Container (
                                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.7),
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
                                            child: FetchInfoFromDb.itemOfProfilesList(state.getUser()!.id)
                                        ),
                                        Positioned(
                                            right: 5,
                                            top: 5,
                                            child: PushButton(icon: Icons.add, onPressed: () => MaterialPageRoute(builder: (context) => ProfileEditScreen.create()))
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ///User chats block
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Container (
                                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 7, maxHeight: MediaQuery.of(context).size.height / 4.7),
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
                                            child: FetchInfoFromDb.itemOfUserChatsList(state.getUser()!.id)
                                        ),
                                        Positioned(
                                            right: 5,
                                            top: 5,
                                            child: PushButton(icon: Icons.add, onPressed: () => MaterialPageRoute(builder: (context) => ChatEditScreen.create()))
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
}