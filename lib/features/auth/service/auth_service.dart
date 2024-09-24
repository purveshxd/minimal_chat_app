import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimal_chat_app/model/user_model.dart';

class AuthService {
  // instance of firebase
  final FirebaseAuth auth = FirebaseAuth.instance;

  // instance of cloud firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // sign-in
  Future<UserCredential> loginWithEmailPassword(
      String password, String email) async {
    try {
      log(email);
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
// get friend list
      final userData = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get()
          .then(
        (value) {
          return value.get('friendsList') as List;
        },
      );

      // save data to doc
      firestore.collection('users').doc(userCredential.user!.uid).update(
          UserModel(
                  email: email,
                  id: userCredential.user!.uid,
                  friendsList: userData)
              .toMap());
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // signout
  Future<void> logout() async {
    return await auth.signOut();
  }

  // register
  Future<UserCredential> registerWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // save data to doc
      firestore.collection('users').doc(userCredential.user!.uid).set(
          UserModel(email: email, id: userCredential.user!.uid, friendsList: [])
              .toMap());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
