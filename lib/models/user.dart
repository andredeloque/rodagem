import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({this.email, this.password, this.name, this.id, this.typeUser});

  User.fromDocument(DocumentSnapshot document) {
    id = document.documentID;
    name = document.data['name'] as String;
    email = document.data['email'] as String;
    typeUser = document.data['typeUser'] as String;
  }

  String id;
  String name;
  String email;
  String password;
  String typeUser;

  String confirmPassword;

  String checkTypeUser (bool typeUser) {
    return typeUser ? "motorista" : "transportadora";
  }
  DocumentReference get firestoreRef =>
      Firestore.instance.document('users/$id');

  Future<void> saveData() async {
    await firestoreRef.setData(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'typeUser': typeUser,
    };
  }
}
