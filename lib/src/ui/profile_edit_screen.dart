import 'dart:math';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/models/user.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/Utils.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';
import 'package:roleplaying_app/src/ui/profile_screen.dart';
import 'package:roleplaying_app/src/ui/user_profile_screen.dart';

import '../services/auth_service.dart';

late Profile _profile;
late bool _profileCreateFlag;

class ProfileEditScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  Profile? profile;

  ProfileEditScreen.edit({Key? key, required this.profile}) : super(key: key) {
    _profile = profile!;
    _profileCreateFlag = false;
  }
  ProfileEditScreen.create({Key? key}) : super(key: key) {
    _profileCreateFlag = true;
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileEditView();
  }
}

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({Key? key}) : super(key: key);

  @override
  State<ProfileEditView> createState() => _ProfileEditView();
}

class _ProfileEditView extends State<ProfileEditView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  final ProfileService _profileService = ProfileService();

  late String title;
  late String text;

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = context.read<AuthBloc>();
    final user = authBloc.state.getUser()!.id;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateAuthenticated) {
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
                          Profile profile = Profile(user, title, text);
                          if (!_profileCreateFlag) {
                            _profile.text = text;
                            _profile.title = title;
                          }
                          !_profileCreateFlag ? _profileService.updateProfile(_profile) : _profileService.addProfile(profile);
                          !_profileCreateFlag ? Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: _profile))) : Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen()));
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
                          child: ListView(
                            children: [
                              ///Title block
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.8,
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
                                            controller: !_profileCreateFlag ? (_titleController..text = _profile.title) : _titleController,
                                          )
                                      ),
                                    ),
                                  ),
                                  ///Image container
                                  Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 40),
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
                                ],
                              ),
                              Column(
                                children: [
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
                                                        child: Neumorphic(
                                                          style: NeumorphicStyle(
                                                            shape: NeumorphicShape.flat,
                                                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                                            depth: 2.0,
                                                            color: Theme.of(context).accentColor,
                                                          ),
                                                          child: TextField(
                                                            textAlignVertical: TextAlignVertical.top,
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
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80, bottom: 20),
                                    child: Container(
                                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 3.4,),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width / 1.3,
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
                                                controller: !_profileCreateFlag ? (_textController..text = _profile.text) : _textController,
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  )
                                ],
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
