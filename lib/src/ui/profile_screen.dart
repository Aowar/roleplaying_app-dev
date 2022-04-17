import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/models/user.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/Utils.dart';

import '../services/auth_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  final String profileId;

  ProfileScreen({Key? key, required this.profileId}) : super(key: key);

  Widget build(BuildContext context) {
    return ProfileView(profileId: profileId);
  }
}

class ProfileView extends StatefulWidget {
  final String profileId;
  ProfileView({Key? key, required this.profileId}) : super(key: key) {
  }

  @override
  State<ProfileView> createState() => _ProfileView();
}

class _ProfileView extends State<ProfileView> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  ProfileService _profileService = ProfileService();

  late String title;
  late String text;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = context.read<AuthBloc>();
    final user = authBloc.state.getUser()!.id;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateAuthetificated) {
          return Scaffold(
            body: Stack(
              children: [
                ///Building back button
                Positioned(top: 15, left: 15, child: Utils.GenerateBackButton(context)),
                ///Building apply button
                Positioned(
                    top: 15,
                    right: 15,
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        depth: 5.0,
                        color: Theme.of(context).primaryColor,
                        boxShape: const NeumorphicBoxShape.circle(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.check),
                        color: Colors.white,
                        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                        onPressed: () async {
                          title = _titleController.text;
                          text = _textController.text;
                          Profile _form = Profile(user, title, text);
                          _profileService.addProfile(_form);
                          Navigator.pop(context);
                        },
                      ),
                    )
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.height / 1.15,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                          depth: 2.0,
                          color: Theme.of(context).cardColor,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              ///Title block
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.height / 22,
                                  child: Neumorphic(
                                      style: NeumorphicStyle(
                                          shape: NeumorphicShape.convex,
                                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                                          depth: 5.0,
                                          color: Theme.of(context).accentColor
                                      ),
                                      child: TextField(
                                        textAlignVertical: TextAlignVertical.center,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline1,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Название",
                                        ),
                                        controller: _titleController,
                                      )
                                  ),
                                ),
                              ),
                              ///Image container
                              Padding(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                  child: SizedBox(
                                    child: NeumorphicButton(
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.flat,
                                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                        depth: 5.0,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      child:
                                      Icon(Icons.image_outlined,
                                        size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*45),
                                      ),
                                      onPressed: () => Navigator.pushNamed(context, ''),
                                    ),
                                  )
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 60),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.27,
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                      depth: 2.0,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 50, left: MediaQuery.of(context).size.width / 30),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Текст:",
                                                  style: Theme.of(context).textTheme.bodyText2,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 15),
                                                  child: SizedBox(
                                                    width: MediaQuery.of(context).size.width / 2,
                                                    height: MediaQuery.of(context).size.height / 28,
                                                    child: Neumorphic(
                                                      style: NeumorphicStyle(
                                                        shape: NeumorphicShape.flat,
                                                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                                        depth: 2.0,
                                                        color: Theme.of(context).accentColor,
                                                      ),
                                                      child: TextField(
                                                        textAlignVertical: TextAlignVertical.center,
                                                        textAlign: TextAlign.center,
                                                        decoration: InputDecoration(
                                                            border: InputBorder.none,
                                                            hintText: "Текст",
                                                            hintStyle: TextStyle(
                                                              color: Theme.of(context).textTheme.bodyText1?.color,
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80, bottom: 10),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.5,
                                                child: NeumorphicButton(
                                                    style: NeumorphicStyle(
                                                      shape: NeumorphicShape.flat,
                                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                                      depth: 2.0,
                                                      color: Theme.of(context).cardColor,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width) / 3),
                                                      ),
                                                    ),
                                                    onPressed: () => {}),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.3,
                                  height: MediaQuery.of(context).size.height / 3.4,
                                  child: Neumorphic(
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.flat,
                                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                        depth: 2.0,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: TextField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Текст",
                                              hintStyle: TextStyle(
                                                color: Theme.of(context).textTheme.bodyText1?.color,
                                              )
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                              )
                            ],
                          ),
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

  void confirmButtonAction(BuildContext context) async {
    title = _titleController.text;
    text = _textController.text;

    Profile _form = Profile(context.select((AuthBloc bloc) => bloc.state.getUser()!.id), title, text);

    print(_form.toString());

    _profileService.addProfile(_form);

    Navigator.pop(context);
  }
}
