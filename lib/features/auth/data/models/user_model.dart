import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.nom,
    required super.identifiant,
    required super.zone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        nom: json['nom'] as String,
        identifiant: json['identifiant'] as String,
        zone: json['zone'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'identifiant': identifiant,
        'zone': zone,
      };

  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String source) =>
      UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
