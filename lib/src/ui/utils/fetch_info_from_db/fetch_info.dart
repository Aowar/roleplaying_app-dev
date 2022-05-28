import 'package:flutter/material.dart';
import 'package:roleplaying_app/src/ui/utils/fetch_info_from_db/blocks_builder.dart';

import '../../../models/chat.dart';
import '../../../models/profile.dart';
import '../../../services/chat_service.dart';
import '../../../services/profile_service.dart';

class FetchInfoFromDb {

  ///Getting profiles from DB
  static itemOfProfilesList(String userId) {
    return StreamBuilder<List<Profile>>(
      stream: ProfileService().readProfiles(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Ошибка получения данных" + snapshot.error.toString(), style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
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

  ///Getting chats from DB
  static itemOfChatsList() {
    return StreamBuilder<List<Chat>>(
      stream: ChatService().readChats(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
          final chats = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ChatBlock(chat: chats[index]);
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

  ///Getting user chats from DB
  static itemOfUserChatsList(String userId) {
    return StreamBuilder<List<Chat>>(
      stream: ChatService().readUserChats(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Ошибка получения данных", style: Theme.of(context).textTheme.subtitle2);
        }
        if (snapshot.hasData) {
          final chats = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ChatBlock(chat: chats[index]);
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