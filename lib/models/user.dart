import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User {
  User(
      {this.email,
      this.id,
      this.userName,
      this.bio,
      this.fullName,
      this.photoUrl});

  final String id;
  final String email;
  final String photoUrl;
  final String userName;
  final String fullName;
  final String bio;

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      userName: doc['username'],
      photoUrl: doc['photoUrl'],
      bio: doc['bio'],
      fullName: doc['fullname'],
    );
  }
}
