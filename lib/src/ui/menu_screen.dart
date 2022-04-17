import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/auth_screen.dart';
import 'package:roleplaying_app/src/ui/profile_edit_screen.dart';
import 'package:roleplaying_app/src/ui/profile_screen.dart';

import 'Utils.dart';

class MenuScreen extends StatefulWidget{

  MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

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

  ///Getting list stream of profiles where id of current user = user id in profile
  Stream<List<Profile>> _readProfiles(AuthState state) => FirebaseFirestore.instance.collection("profiles").where("userId", isEqualTo:  state.getUser()!.id).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Profile.fromJson(doc.data())).toList()
  );

  ///Building profile block
  Widget buildProfile(Profile profile) => SizedBox(
    height: 100,
    child: Column(
          children: [
            NeumorphicButton(
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                depth: 5.0,
                color: Theme.of(context).accentColor,
              ),
              child:
              Icon(Icons.image_outlined,
                size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*3),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen.edit(profile: profile))),
            ),
            Text(profile.title,
                style: Theme.of(context).textTheme.subtitle2),
          ],
        )
  );

  ///Getting profiles from DB
  itemOfProfilesList(AuthState state) {
    return StreamBuilder<List<Profile>>(
      stream: _readProfiles(state),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
          final profiles = snapshot.data!;
          return Padding(
              padding: EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: profiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildProfile(profiles[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                    ),
                  )
                ],
              )
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateAuthetificated) {
            return Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Utils.GenerateButton('/profile_screen', Icons.account_circle_sharp, context),
                  ),
                  Positioned(
                      right: 15,
                      top: 15,
                      child: Utils.GenerateButton('/auth_screen', Icons.logout, context)
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4.5),
                      child: Center(
                        child: Column(
                          children: [
                            generateMenuBlock(_containersNames[0], '/chat_screen'),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child:  SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                height: MediaQuery.of(context).size.height / 4.8,
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
                                        child: itemOfProfilesList(state)
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
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: generateMenuBlock(_containersNames[2], '/chat_screen', true, '/chat_edit_screen', Icons.add),
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