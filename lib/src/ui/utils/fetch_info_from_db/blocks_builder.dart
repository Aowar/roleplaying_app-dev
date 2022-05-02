import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ChatScreen(chat: chat)));
            },
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: profile))),
          ),
          Text(profile.title,
              style: Theme.of(context).textTheme.subtitle2
          ),
        ],
      )
  );
}