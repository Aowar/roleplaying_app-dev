import 'package:equatable/equatable.dart';

class CustomUserModel extends Equatable {

  String? idUser;
  String? nickName;

  CustomUserModel(this.idUser, this.nickName);

  CustomUserModel.fromJson(Map<String, dynamic> data) {
    idUser = data['userId'];
    nickName = data['nickName'];
  }

  @override
  List<Object?> get props => [idUser, nickName];

  Map<String, dynamic> toMap() {
    return {
      "userId": idUser,
      "nickName": nickName
    };
  }
}