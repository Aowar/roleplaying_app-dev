import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/chat.dart';
import '../../../models/profile.dart';
import '../../chat_screen.dart';
import '../../profile_screen.dart';

class BlocksBuilder {
  ///Building chat block
  static Widget buildChat(BuildContext context, Chat chat) => SizedBox(
      height: 100,
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).accentColor.withOpacity(0.2),
                    spreadRadius: 5,
                    offset: const Offset(5, 5),
                    blurRadius: 10
                  )
                ]
              ),
              child: Icon(Icons.image_outlined,
                  size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*3),
                ),
              ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat: chat))),
          ),
          Text(chat.title,
              style: Theme.of(context).textTheme.subtitle2
          ),
        ],
      )
  );

  ///Building profile block
  static Widget buildProfile(BuildContext context, Profile profile) => SizedBox(
      height: 100,
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).accentColor.withOpacity(0.2),
                        spreadRadius: 5,
                        offset: const Offset(5, 5),
                        blurRadius: 10
                    )
                  ]
              ),
              child: Icon(Icons.image_outlined,
                  size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*3),
                ),
              ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: profile))),
          ),
          Text(profile.title,
              style: Theme.of(context).textTheme.subtitle2
          ),
        ],
      )
  );
}