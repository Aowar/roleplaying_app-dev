import 'package:equatable/equatable.dart';

class CustomUserModel extends Equatable {

  late String idUser;
  late String nickName;
  late String image;

  CustomUserModel({required this.idUser, required this.nickName, required this.image});

  CustomUserModel.fromJson(Map<String, dynamic> data) {
    idUser = data['userId'];
    nickName = data['nickName'];
    image = data['image'];
  }

  @override
  List<Object?> get props => [idUser, nickName, image];

  Map<String, dynamic> toMap() {
    return {
      "userId": idUser,
      "nickName": nickName,
      "image": image
    };
  }
}