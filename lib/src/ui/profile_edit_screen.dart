import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart' as utils;
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/menu_screen.dart';

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
                ///Building apply button
                Positioned(
                    top: 15,
                    right: 15,
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
                          icon: const Icon(Icons.check),
                          color: Colors.white,
                          iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                          onPressed: () {
                            title = _titleController.text;
                            text = _textController.text;
                            _profileCreateFlag ? _profile = Profile(state.getUser()!.id, title, text, 'null') :
                            { _profile.title = title, _profile.text = text };
                            _profileCreateFlag ? ProfileService().addProfile(_profile) : ProfileService().updateProfile(_profile);
                            Navigator.pop(context);
                          }
                      ),
                    )
                ),
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
                                  spreadRadius: 2,
                                  offset: const Offset(5, 5),
                                  blurRadius: 10
                              )
                            ]
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
                                      child: Container(
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
                                        child: SizedBox(
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  )
                                              ),
                                            ),
                                            onPressed: () => Navigator.pushNamed(context, ' '),
                                            child:
                                            Icon(Icons.image_outlined,
                                              size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*45),
                                            ),
                                          ),
                                        )
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80, bottom: 20),
                                    child: Container(
                                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 3.4,),
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

    Profile _form = Profile(context.select((AuthBloc bloc) => bloc.state.getUser()!.id), title, text, 'null');

    _profileService.addProfile(_form);

    Navigator.pop(context);
  }
}
