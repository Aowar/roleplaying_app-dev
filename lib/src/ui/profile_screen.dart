import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/profile_edit_screen.dart';

import '../services/auth_service.dart';
import 'auth_screen.dart';

late Profile _profile;

class ProfileScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  final Profile profile;

  ProfileScreen({Key? key, required this.profile}) : super(key: key) {
    _profile = profile;
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileView();
}

class _ProfileView extends State<ProfileView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  late String title = _profile.title;
  late String text = _profile.text;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateAuthenticated) {
          return Scaffold(
            body: Stack(
              children: [
                ///Building back button
                const Positioned(
                    top: 15,
                    left: 15,
                    child: utils.BackButton()
                ),
                ///Building edit button
                if (state.getUser()!.id == _profile.userId) ...[
                  Positioned(
                    top: 15,
                    right: 15,
                    child: utils.PushButton(icon: Icons.edit, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.edit(profile: _profile)))),
                  ),
                ],
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.height / 1.15,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5.0),
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
                        child: ListView(
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  ///Title block
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      child: Container(
                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.secondary,
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                                    spreadRadius: 5,
                                                    offset: const Offset(5, 5),
                                                    blurRadius: 10
                                                )
                                              ]
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5, top: 2, bottom: 2, right: 5),
                                            child: TextField(
                                              maxLines: 1,
                                              textAlignVertical: TextAlignVertical.center,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.headline1,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Название",
                                              ),
                                              controller: _titleController..text = _profile.title,
                                              readOnly: true,
                                            )
                                          ),
                                      ),
                                    ),
                                  ),
                                  ///Image container
                                  Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: SizedBox.square(
                                        dimension: sqrt(MediaQuery.of(context).size.width + MediaQuery.of(context).size.height) * 8,
                                        child: FutureBuilder<String>(
                                          future: FileService().getProfileImage(_profile.id, _profile.image),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const LinearProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              Fluttertoast.showToast(
                                                  msg: "Письмо отправлено на указанный адрес",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 3,
                                                  backgroundColor: Colors.green,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              );
                                              return const Icon(Icons.image_outlined);
                                            } else {
                                              return Container(
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0),
                                                    borderRadius: const BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(snapshot.data!),
                                                      fit: BoxFit.fitHeight,
                                                      alignment: FractionalOffset.topCenter,
                                                    )
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                    child: Container(
                                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 3.4),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width / 1.3,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.secondary,
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(5.0),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      offset: const Offset(5, 5),
                                                      blurRadius: 10
                                                  )
                                                ]
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: TextField(
                                                keyboardType: TextInputType.multiline,
                                                maxLines: null,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Текст",
                                                    hintStyle: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyText1?.color,
                                                    )
                                                ),
                                                controller: _textController..text = text,
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return AuthScreen();
      },
    );
  }
}
