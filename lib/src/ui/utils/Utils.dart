import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/services/auth_service.dart';

class Utils{
  static GenerateButton(String _route, IconData icon, BuildContext context){
    return Container(
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
        icon: Icon(icon),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: () => Navigator.pushNamed(context, _route),
      ),
    );
  }

  static GenerateLogOutButton(String _route, AuthService authService, IconData icon, BuildContext context, AuthBloc authBloc){
    return Container(
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
        icon: Icon(icon),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: () {
          authService.logOut();
          authBloc.add(const UserLoggedOut());
          Navigator.pushNamed(context, _route);
        },
      ),
    );
  }

  static GenerateButton2(IconData icon, BuildContext context, MaterialPageRoute materialPageRoute){
    return Container(
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
        icon: Icon(icon),
        color: Colors.white,
        iconSize: sqrt(MediaQuery.of(context).size.height + MediaQuery.of(context).size.width),
        onPressed: () => Navigator.push(context, materialPageRoute),
      ),
    );
  }

  static GenerateBackButton(BuildContext context){
    return Container(
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
        icon: const Icon(Icons.arrow_back_ios_rounded),
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
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).accentColor.withOpacity(0.2),
                  spreadRadius: 2,
                  offset: const Offset(5, 5),
                  blurRadius: 10
              )
            ]
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