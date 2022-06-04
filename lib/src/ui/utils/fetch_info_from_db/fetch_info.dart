import 'package:flutter/material.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/profile_service.dart';
import 'package:roleplaying_app/src/ui/utils/Utils.dart';
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/blocks_builder.dart';

class ProfilesList extends StatelessWidget {
  final String userId;
  Stream<List<Profile>>? stream;
  ProfilesList ({Key? key, required this.userId, this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    stream ??= ProfileService().readProfiles(userId);
    return StreamBuilder<List<Profile>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Toasts.showErrorMessage(errorMessage: "Ошибка получения данных\n" + snapshot.error.toString());
          return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
          if(snapshot.data!.isEmpty) {
            return Text("Пусто", style: Theme.of(context).textTheme.subtitle1);
          }
          final profiles = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: profiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ProfileBlock(profile: profiles[index]);
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
}