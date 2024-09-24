import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal_chat_app/features/chatlist/service/chat_service.dart';
import 'package:minimal_chat_app/features/chatlist/view/user_tile.dart';
import 'package:minimal_chat_app/features/profile/view/profile_view.dart';
import 'package:minimal_chat_app/features/qr_scanner/view/qr_scanner_view.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileView(),
                  ));
            },
            icon: const Icon(Icons.person_rounded),
          )
        ],
      ),
      body: Center(
        child: SafeArea(
          child: StreamBuilder(
              // stream: ChatService().getUserFriendsList().map(
              //   (event) {
              //     return event.where(
              //       (element) {
              //         return element.id ==
              //             FirebaseAuth.instance.currentUser!.uid;
              //       },
              //     );
              //   },
              // ),
              stream: ChatService().getFriendList(),
              builder: (context, snapshot) {
                // errors
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );

                  // Loading...
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());

                  // Return Friends list
                } else {
                  log("---${snapshot.data}");
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.elementAt(index) ==
                            FirebaseAuth.instance.currentUser!.uid) {
                          return const SizedBox();
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: UserTile(
                              friendId: snapshot.data!.elementAt(index),
                            ),
                          );
                        }
                      });
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // TODO: add camera and QR functionality here

          // get camera permissions
          var cameraStatus = await Permission.camera.status;
          if (!cameraStatus.isGranted) {
            await Permission.camera.request();
          }
          if (context.mounted) {
            // open QR scanner
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BarcodeScannerSimple()),
            );
          }
        },
        label: const Text("Add"),
        icon: const Icon(Icons.qr_code_rounded),
      ),
    );
  }
}
