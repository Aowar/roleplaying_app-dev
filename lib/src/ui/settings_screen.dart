import 'dart:developer' as dev;
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/main.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/custom_user_model.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';
import 'package:roleplaying_app/src/services/custom_user_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  final CustomUserModel user;
  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsView(user: user);
  }
}

class SettingsView extends StatefulWidget {
  final CustomUserModel user;
  const SettingsView({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late SharedPreferences _prefs;
  bool isNightTheme = false;
  TextEditingController nickNameFieldController = TextEditingController();
  ThemeMode themeMode = ThemeMode.light;

  getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  clearAccountInPrefs() async {
    await getPrefs();
    _prefs.remove("email");
    _prefs.remove("password");
  }

  getDataFromPrefs() async {
    await getPrefs();
    if (_prefs.containsKey("isNightTheme")) {
      isNightTheme = _prefs.getBool("isNightTheme")!;
      setState(() {

      });
    }
  }

  setDataToPrefs() {
    _prefs.setBool("isNightTheme", isNightTheme);
    dev.log(_prefs.getBool("isNightTheme").toString(), name: "isNightTheme?");
  }

  changeNickname() async {
    widget.user.nickName = nickNameFieldController.text;
    await FirebaseAuth.instance.currentUser!.updateDisplayName(nickNameFieldController.text);
    await CustomUserService().updateCustomUser(widget.user);
  }


  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    getDataFromPrefs();
    themeMode = isNightTheme ? ThemeMode.dark : ThemeMode.light;
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
                const Positioned(
                  top: 16,
                  left: 16,
                  child: utils.BackButton(),
                ),
                Positioned(
                    right: 16,
                    top: 16,
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
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                          shape: MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                        ),
                        child: Icon(Icons.logout,
                            color: Colors.white,
                            size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width))),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: ListTile(
                                  title: Text(
                                      "Вы точно хотите выйти из аккаунта?",
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
                                            clearAccountInPrefs();
                                            AuthService().logOut();
                                            authBloc.add(const UserLoggedOut());
                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthScreen()), (route) => false);
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
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3, left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 6, maxWidth: MediaQuery.of(context).size.width / 1.5),
                          child: Column(
                            children: [
                              Text(
                                "Изменить никнейм:",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0),
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
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                  child: TextField(
                                    maxLines: 1,
                                    textAlignVertical: TextAlignVertical.center,
                                    textAlign: TextAlign.left,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Введите никнейм",
                                    ),
                                    controller: nickNameFieldController..text = widget.user.nickName,
                                    onSubmitted: (String value) {
                                      changeNickname();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(const CircleBorder()),
                                backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                alignment: isNightTheme ? Alignment.centerLeft : Alignment.center
                            ),
                            onPressed: () {
                              isNightTheme = !isNightTheme;
                              setDataToPrefs();
                              isNightTheme ? themeMode = ThemeMode.dark : themeMode = ThemeMode.light;
                              RpApp.of(context)!.changeTheme(themeMode);
                              setState(() {

                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Icon(
                                isNightTheme ? Icons.nightlight_round_sharp : Icons.sunny,
                                size: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width) * 1.5,
                                color: isNightTheme ? const Color(0xFF4DAD55) : Colors.white,
                              ),
                            )
                        )
                      ],
                    )
                ),
              ],
            ),
          );
        } else {
          return AuthScreen();
        }
      }
    );
  }
}

