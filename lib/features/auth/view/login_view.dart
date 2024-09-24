import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_chat_app/features/auth/components/auth_text_field.dart';
import 'package:minimal_chat_app/features/auth/providers/authProviders.dart';
import 'package:minimal_chat_app/features/auth/service/auth_service.dart';

class LoginView extends ConsumerWidget {
  LoginView({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // login method
    login() async {
      try {
        await AuthService().loginWithEmailPassword(
            passwordController.text.trim(), emailController.text.trim());
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // main icon
              Icon(
                Icons.chat_bubble_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 25),

              // Welcome message
              const Text(
                "Welcome back!",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),

              // email textField
              AuthTextField(
                hintText: "Email",
                textController: emailController,
              ),
              const SizedBox(height: 12),

              // password textField
              AuthTextField(
                hintText: "Password",
                obscureText: ref.watch(obscureTextProvider),
                textController: passwordController,
                toggleObscureText: () {
                  ref.watch(obscureTextProvider.notifier).update(
                        (state) => !state,
                      );
                },
              ),

              const SizedBox(height: 12),
              // Login button
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      style: const ButtonStyle(),
                      onPressed: () {
                        login();
                        log("User logged in");
                      },
                      child: const Text("Login"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Not a user?",
                    style: TextStyle(),
                  ),
                  TextButton(
                      onPressed: () {
                        ref.watch(registerOrLoginProvider.notifier).update(
                              (state) => !state,
                            );
                      },
                      child: const Text("Register"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
