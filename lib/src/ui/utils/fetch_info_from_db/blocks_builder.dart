import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roleplaying_app/src/services/file_service.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart';
import '../../../models/profile.dart';
import '../../profile/profile_screen.dart';

///Building profile block
class ProfileBlock extends StatelessWidget {
  final Profile profile;

  const ProfileBlock({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: SizedBox(
        width: sqrt(MediaQuery.of(context).size.width) * 4.5,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Theme.of(context).primaryColor),
              borderRadius: const BorderRadius.all(Radius.circular(5))
          ),
          child: Column(
            children: [
              CustomSquareIconButton(
                  future: FileService().getProfileImage(profile.id, profile.image),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profile: profile))),
                  scale: 2
              ),
              Flexible(
                child: Text(profile.title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}