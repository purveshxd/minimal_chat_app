// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal_chat_app/features/auth/service/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileView extends StatefulWidget {
  final String? username;
  const ProfileView({super.key, this.username});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
  }

  String? getUsername() {
    if (widget.username == null) {
      String? usernameInside = FirebaseAuth.instance.currentUser!.email;
      return usernameInside;
    } else {
      return widget.username;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Future<String> getQr() {
    //   return ChatService().getUserInfo(widget.username!).then(
    //     (value) {
    //       return value.id;
    //     },
    //   );
    // }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Main profile image of the user
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          minRadius: 50,
                          child: Icon(
                            Icons.person_rounded,
                            size: 70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // name and email of the user
                        Text(
                          getUsername()!.split('@')[0],
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),

                        Text(
                          getUsername()!,
                        ),
                      ],
                    ),
                  ),
                ]),

            Container(
              margin: const EdgeInsets.all(20),
              clipBehavior: Clip.hardEdge,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(25)),
              child: QrImageView(
                gapless: true,
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                data: FirebaseAuth.instance.currentUser!.uid,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                version: 2,
                padding: const EdgeInsets.all(25),
              ),
            ),
// Logout button for user
            Visibility(
                visible: widget.username == null,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    AuthService().logout().then(
                          (value) => Navigator.of(context).pop(),
                        );

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: StadiumBorder(),
                        content: Text("User logged out")));
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Logout"),
                )),
          ],
        ),
      ),
    );
  }
}
