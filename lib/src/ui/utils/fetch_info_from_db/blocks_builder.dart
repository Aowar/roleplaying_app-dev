import 'dart:math';

import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import '../../../models/profile.dart';
import '../../chat_screen.dart';
import '../../profile_screen.dart';

class BlocksBuilder {
  ///Building profile block
  static Widget buildProfile(BuildContext context, Profile profile) => SizedBox(
      height: 100,
      child: Column(
        children: [
          SizedBox(
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(profile: profile))),
              child:
              Icon(Icons.image_outlined,
                size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*3),
              ),
            ),
          ),
          Text(profile.title,
              style: Theme.of(context).textTheme.subtitle2
          ),
        ],
      )
  );
}

///Building chat block
class ChatBlock extends StatelessWidget {
  final Chat chat;

  const ChatBlock({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100,
        child: Column(
          children: [
            SizedBox(
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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat: chat))),
                child:
                Icon(Icons.image_outlined,
                  size: sqrt((MediaQuery.of(context).size.height + MediaQuery.of(context).size.width)*3),
                ),
              ),
            ),
            Text(chat.title,
                style: Theme.of(context).textTheme.subtitle2
            ),
          ],
        )
    );
  }
}
