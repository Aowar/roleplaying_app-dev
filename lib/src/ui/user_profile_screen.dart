import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';
import 'package:roleplaying_app/src/ui/Utils.dart';

late String _userId;

class UserProfileScreen extends StatefulWidget{
  String userId;

  UserProfileScreen({Key? key, required this.userId}) : super(key: key) {
    _userId = userId;
  }

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  Stream<List<CustomUserModel>> _readUser(String userId) => FirebaseFirestore.instance.collection("users").where("userId", isEqualTo:  _userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => CustomUserModel.fromJson(doc.data())).toList()
  );

  ///Getting user
  userNickName(String userId) {
    return StreamBuilder<List<CustomUserModel>>(
      stream: _readUser(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: user.length,
                      itemBuilder: (BuildContext context, int index) {
                         return Text(user[index].nickName.toString(),
                            style: Theme.of(context).textTheme.headline2
                        );
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 15,
            top: 15,
            child: Utils.GenerateBackButton(context)
          ),
          Center(
            child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                child: Column(
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        depth: 3.5,
                        color: Theme.of(context).primaryColor,
                        boxShape: const NeumorphicBoxShape.circle(),
                      ),
                      child: Icon(Icons.account_circle_sharp,
                        size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*20),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 40),
                      child: Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 40,
                          width: MediaQuery.of(context).size.height / 5,
                          child: Container(
                            child: userNickName(_userId),
                          )
                        ),
                      )
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 40),
                    //   child: SizedBox(
                    //     width: MediaQuery.of(context).size.width / 1.1,
                    //     height: MediaQuery.of(context).size.height / 1.9,
                    //     child: Neumorphic(
                    //       style: NeumorphicStyle(
                    //         shape: NeumorphicShape.flat,
                    //         boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                    //         depth: 2.0,
                    //         color: Theme.of(context).cardColor,
                    //       ),
                    //       child: Stack(
                    //         children: [
                    //           Positioned(
                    //             left: 15,
                    //             top: 10,
                    //             child: Text("Комментарии:",
                    //               style: Theme.of(context).textTheme.headline2,
                    //             ),
                    //           ),
                    //           Center(
                    //             child: Padding(
                    //                 padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
                    //                 child: Column(
                    //                   children: [
                    //                     Utils.GenerateMessageContainer('/profile_screen', Icons.account_circle_sharp, context, 'Пользователь 2'),
                    //                     Center(
                    //                       child: Padding(
                    //                         padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5, left: MediaQuery.of(context).size.width / 90),
                    //                         child: Row(
                    //                           children: [
                    //                             SizedBox(
                    //                               width: MediaQuery.of(context).size.width / 1.35,
                    //                               height: MediaQuery.of(context).size.height / 22.8,
                    //                               child: SizedBox(
                    //                                 width: MediaQuery.of(context).size.width / 1.5,
                    //                                 height: MediaQuery.of(context).size.height / 50,
                    //                                 child: Neumorphic(
                    //                                     style: NeumorphicStyle(
                    //                                         shape: NeumorphicShape.convex,
                    //                                         boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                    //                                         depth: 5.0,
                    //                                         color: Theme.of(context).accentColor
                    //                                     ),
                    //                                     child: Padding(
                    //                                       padding: EdgeInsets.only(left: 10),
                    //                                       child: TextField(
                    //                                           decoration: InputDecoration(
                    //                                               border: InputBorder.none,
                    //                                               hintText: "Комментарий",
                    //                                               hintStyle: TextStyle(
                    //                                                   color: Theme.of(context).textTheme.bodyText2?.color
                    //                                               )
                    //                                           )
                    //                                       ),
                    //                                     )
                    //                                 ),
                    //                               )
                    //                             ),
                    //                             Padding(
                    //                               padding: EdgeInsets.only(left: 5),
                    //                               child: Utils.GenerateButton('', Icons.arrow_forward_ios_rounded, context),
                    //                             )
                    //                           ],
                    //                         )
                    //                       ),
                    //                     )
                    //                   ],
                    //                 )
                    //             ),
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }
}