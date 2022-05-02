import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/services/chat_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/chat_edit_screen.dart';
import 'package:roleplaying_app/src/ui/chat_screen.dart';
import 'package:roleplaying_app/src/ui/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/profile_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/fetch_info.dart';

import 'utils/Utils.dart';

class MenuScreen extends StatefulWidget{

  MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final AuthService _authService = AuthService();

  final List<String> _containersNames = ["Открытые чаты", "Мои анкеты", "Мои чаты"];

  generateMenuBlock(String _containersName, String route, [bool? _buttonFlag, String? _route, IconData? icon]){
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.1,
      height: MediaQuery.of(context).size.height / 5.2,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          depth: 2.0,
          color: Theme.of(context).cardColor,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Text(_containersName,
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 35),
              child: Column(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 4.5,
                      height: MediaQuery.of(context).size.height / 8.4,
                      child: NeumorphicButton(
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                          depth: 5.0,
                          color: Theme.of(context).accentColor,
                        ),
                        child: Icon(Icons.image_outlined,
                            size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*3),
                        ),
                        onPressed: () => Navigator.pushNamed(context, route),
                      )
                  )
                ],
              ),
            ),
            if (_buttonFlag == true)
              Positioned(
                  right: 15,
                  top: 15,
                  child: Utils.GenerateButton(_route!, icon!, context)
              )
          ],
        ),
      ),
    );
  }

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
                    child: Utils.GenerateButton2(Icons.account_circle_sharp, context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: state.getUser()!.id))),
                  ),
                  Positioned(
                      right: 15,
                      top: 15,
                      child: Utils.GenerateLogOutButton('/auth_screen', _authService, Icons.logout, context, authBloc)
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
                                child: Neumorphic(
                                  style: NeumorphicStyle(
                                    shape: NeumorphicShape.flat,
                                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                                    depth: 2.0,
                                    color: Theme.of(context).cardColor,
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
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                                      depth: 2.0,
                                      color: Theme.of(context).cardColor,
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
                                            child: FetchInfoFromDb.itemOfProfilesList(state)
                                        ),
                                        Positioned(
                                            right: 5,
                                            top: 5,
                                            child: Utils.GenerateButton2(Icons.add, context, MaterialPageRoute(builder: (context) => ProfileEditScreen.create()))
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
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                                      depth: 2.0,
                                      color: Theme.of(context).cardColor,
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
                                            child: Utils.GenerateButton2(Icons.add, context, MaterialPageRoute(builder: (context) => ProfileEditScreen.create()))
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