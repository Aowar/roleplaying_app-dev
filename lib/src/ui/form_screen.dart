import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/models/user.dart';
import 'package:roleplaying_app/src/services/form_service.dart';
import 'package:roleplaying_app/src/ui/Utils.dart';

import '../services/auth_service.dart';

late String _profileId;

class FormScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  final String profileId;

  FormScreen({Key? key, required this.profileId}) : super(key: key);

  Widget build(BuildContext context) {
    return FormView(profileId: profileId);
  }
}

class FormView extends StatefulWidget {
  final String profileId;
  FormView({Key? key, required this.profileId}) : super(key: key) {
    _profileId = profileId;
  }

  @override
  State<FormView> createState() => _FormView();
}

class _FormView extends State<FormView> {
  late TextEditingController _titleController;
  late TextEditingController _textController;

  FormService _formService = FormService();

  late String _title;
  late String _text;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = context.read<AuthBloc>();
    final _user = authBloc.state.getUser()!.id;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        developer.log(state.getUser().toString(), name: "Current user on form screen");
        developer.log(state.toString(), name: "Current state on form screen");
        if (state is AuthStateAuthetificated) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned(top: 15, left: 15, child: Utils.GenerateBackButton(context)),
                Positioned(
                    top: 15,
                    right: 15,
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        depth: 5.0,
                        color: Theme.of(context).primaryColor,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.check),
                        color: Colors.white,
                        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
                        onPressed: () async {
                          _title = _titleController.text;
                          _text = _textController.text;

                          Profile _form = Profile(_user, _title, _text);

                          print(_form.toString());

                          _formService.addOrUpdateProfile(_form);

                          Navigator.pop(context);
                        },
                      ),
                    )),
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
                              Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  height: MediaQuery.of(context).size.height / 22,
                                  child: Neumorphic(
                                      style: NeumorphicStyle(
                                          shape: NeumorphicShape.convex,
                                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                                          depth: 5.0,
                                          color: Theme.of(context).cardColor),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 10),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: _profileId,
                                          ),
                                          controller: _titleController,
                                        ),
                                      )),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width / 1.38,
                                      height: MediaQuery.of(context).size.height / 3.07,
                                      child: NeumorphicButton(
                                        style: NeumorphicStyle(
                                          shape: NeumorphicShape.flat,
                                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                                          depth: 5.0,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width) * 60),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pushNamed(context, ''),
                                      ))),
                              Padding(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 60),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.27,
                                  height: MediaQuery.of(context).size.height / 9,
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
                                                        decoration: InputDecoration(
                                                            border: InputBorder.none,
                                                            hintText: "Текст",
                                                            hintStyle: TextStyle(
                                                              color: Theme.of(context).textTheme.bodyText1?.color,
                                                            )),
                                                        controller: _textController,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width / 1.5,
                                                height: MediaQuery.of(context).size.height / 30,
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
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void confirmButtonAction(BuildContext context) async {
    _title = _titleController.text;
    _text = _textController.text;

    Profile _form = Profile(context.select((AuthBloc bloc) => bloc.state.getUser()!.id), _title, _text);

    print(_form.toString());

    _formService.addOrUpdateProfile(_form);

    Navigator.pop(context);
  }
}
