import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimal_chat_app/model/message_model.dart';
import 'package:minimal_chat_app/model/user_model.dart';

class ChatService {
// get firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // auth
  final FirebaseAuth auth = FirebaseAuth.instance;

  // get users friend's list
  Stream<List<UserModel>> getUserFriendsList() {
    return firestore.collection('users').snapshots().map(
      (snap) {
        return snap.docs
            .map(
              (doc) {
                return doc.data();
              },
            )
            .toList()
            .map(
              (userInfo) {
                log(UserModel.fromJson(jsonEncode(userInfo)).toString());
                return UserModel.fromJson(jsonEncode(userInfo));
              },
            )
            .toList();
      },
    );
  }

  // send message
  Future<void> sendMessage(
      {required String friendId, required String message}) async {
    final String userId = auth.currentUser!.uid;
    final idList = [userId, friendId];
    final userEmail = auth.currentUser!.email;
    DateTime timestamp = DateTime.now();
    idList.sort();
    final chatRoomId = idList.join('_');
    // log(chatRoomId);
    // log(message.toString());

    // create message
    MessageModel messageModel = MessageModel(
        senderId: userId,
        senderEmail: userEmail!,
        receiverId: friendId,
        message: message,
        timestamp: timestamp);
    // log(messageModel.toString());
    firestore
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("message")
        .add(messageModel.toMap());
  }

  // chat stream
  Stream<List<MessageModel>> getMessage(String friendId) {
    final userId = auth.currentUser!.uid;
    final idList = [userId, friendId];
    idList.sort();
    final chatRoomId = idList.join('_');
    return firestore
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection("message")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map(
      (snap) {
        return snap.docs
            .map(
              (doc) {
                return doc.data();
              },
            )
            .toList()
            .map(
              (msg) {
                log(msg.toString());
                log(MessageModel.fromJson(jsonEncode(msg)).toString());
                return MessageModel.fromJson(jsonEncode(msg));
              },
            )
            .toList();
      },
    );
  }

// get friends list
  Stream<List<dynamic>> getFriendList() {
    return firestore.collection('users').snapshots().map(
      (snap) {
        return snap.docs.firstWhere(
          (element) {
            return element.get('id') == FirebaseAuth.instance.currentUser!.uid;
          },
        ).get('friendsList');
      },
    );
  }

  // get user info
  Future<UserModel> getUserInfo(String userId) {
    return firestore.collection('users').doc(userId).get().then(
      (userInfo) {
        return UserModel.fromJson(jsonEncode(userInfo.data()));
      },
    );
  }

  // add friend
  Future<void> addFriend(String friendId) async {
    final String userId = auth.currentUser!.uid;
    final idList = [userId, friendId];
    final userEmail = auth.currentUser!.email;
    DateTime timestamp = DateTime.now();
    idList.sort();
    final chatRoomId = idList.join('_');

// get friend list
    final userData = await firestore.collection('users').doc(userId).get().then(
      (value) {
        return value.get('friendsList') as List;
      },
    );

    if (!userData.contains(friendId)) {
      userData.add(friendId);
    }
// adding to user friend list
    firestore.collection('users').doc(userId).update({"friendsList": userData});

// getting friend's friend list
    final friendsUserData =
        await firestore.collection('users').doc(friendId).get().then(
      (value) {
        return value.get('friendsList') as List;
      },
    );

    if (!friendsUserData.contains(friendId)) {
      friendsUserData.add(userId);
    }

    // adding to friend's friend list

    firestore
        .collection('users')
        .doc(friendId)
        .update({"friendsList": friendsUserData});

    // create message
    MessageModel messageModel = MessageModel(
        senderId: userId,
        senderEmail: userEmail!,
        receiverId: friendId,
        message: "Hii👋",
        timestamp: timestamp);
    // log(messageModel.toString());
    firestore
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("message")
        .add(messageModel.toMap());
  }
}
