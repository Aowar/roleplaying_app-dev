import 'package:equatable/equatable.dart';

class RolePlayQueue extends Equatable {
  late String id;
  late List users;

  RolePlayQueue(this.users);

  RolePlayQueue.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    users = data['users'];
  }

  @override
  List<Object?> get props => [id, users];

  Map<String, dynamic> toMap() {
    return {
      "users": users,
    };
  }
}