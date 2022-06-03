import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class UserModel extends Equatable {

  /// The current user's email address.
  final String? email;

  final String? nickName;

  /// The current user's id.
  final String id;

  /// {@macro user}
  const UserModel({
    required this.id,
    this.email,
    this.nickName
  });

  /// Empty user which represents an unauthenticated user.
  static const empty = UserModel(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == UserModel.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != UserModel.empty;

  @override
  List<Object?> get props => [email, id];
}