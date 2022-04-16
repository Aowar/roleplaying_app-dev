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

import 'Utils.dart';

class MenuScreen extends StatefulWidget{

  MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final List<String> _containersNames = ["Открытые чаты", "Мои анкеты", "Мои чаты"];

  generateMenuBlock(String _containersName, String route, [bool? _buttonFlag, String? _route, IconData? icon]){ //Как сделать дефолтные значения?
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

  Stream<List<Profile>> _readProfiles() => FirebaseFirestore.instance.collection("profiles").snapshots().map((snapshot) => snapshot.docs.map((doc) => Profile.fromJson(doc.data())).toList());

  Widget buildProfile(Profile profile) => ListTile(
    leading: CircleAvatar(child:  Text('${profile.userId}')),
    title: Text(profile.title),
    subtitle: Text(profile.text),
  );

  itemOfProfilesList() {
    return StreamBuilder<List<Profile>>(
      stream: _readProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData) {
          final profiles = snapshot.data!;

          return Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: profiles.map(buildProfile).toList(),
              )
          );
        }
        return Text("loading");
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
                      child: itemOfProfilesList()
                      // child: Center(
                      //   child: Column(
                      //     children: [
                      //       generateMenuBlock(_containersNames[0], '/chat_screen'),
                      //       Padding(
                      //         padding: const EdgeInsets.only(top: 30),
                      //         child: generateMenuBlock(_containersNames[1], '/form_screen', true, '/form_screen', Icons.add),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.only(top: 30),
                      //         child: generateMenuBlock(_containersNames[2], '/chat_screen', true, '/chat_edit_screen', Icons.add),
                      //       ),
                      //       Padding(
                      //           padding: const EdgeInsets.only(top: 30),
                      //           child: itemOfProfilesList()
                      //       ),
                      //     ],
                      //   ),
                      // )
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
        }
    );
  }
}