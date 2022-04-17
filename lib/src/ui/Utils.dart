import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class Utils{
  static GenerateButton(String _route, IconData icon, BuildContext context){
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 5.0,
        color: Theme.of(context).primaryColor,
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: () => Navigator.pushNamed(context, _route),
      ),
    );
  }

  static GenerateButton2(IconData icon, BuildContext context, MaterialPageRoute materialPageRoute){
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 5.0,
        color: Theme.of(context).primaryColor,
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: () => Navigator.push(context, materialPageRoute),
      ),
    );
  }

  static GenerateBackButton(BuildContext context){
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        depth: 5.0,
        color: Theme.of(context).primaryColor,
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  static GenerateMessageContainer(String _route, IconData icon, BuildContext context, String user){
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      height: MediaQuery.of(context).size.height / 6,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
          depth: 2.0,
          color: Theme.of(context).accentColor,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: Utils.GenerateButton(_route, icon, context),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 100, left: MediaQuery.of(context).size.width / 5.5),
              child: Text(user,
                  style: Theme.of(context).textTheme.subtitle1
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 12, left: MediaQuery.of(context).size.width / 5),
              child: Text("Текст",
                  style: Theme.of(context).textTheme.subtitle2
              ),
            )
          ],
        ),
      ),
    );
  }

}