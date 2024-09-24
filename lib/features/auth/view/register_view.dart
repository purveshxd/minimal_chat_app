import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minimal_chat_app/features/auth/components/auth_text_field.dart';
import 'package:minimal_chat_app/features/auth/providers/authProviders.dart';
import 'package:minimal_chat_app/features/auth/service/auth_service.dart';

class RegisterView extends ConsumerWidget {
  RegisterView({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  @override
  Widget build(BuildContext context, ref) {
    // register method
    register() async {
      if (passwordConfirmController.text == passwordController.text) {
        try {
          await AuthService().registerWithEmailPassword(
              emailController.text.trim(), passwordController.text.trim());
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            alignment: Alignment.center,
            title: Text("Password doesn't match"),
          ),
        );
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
                "Let's Start chating!",
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
                toggleObscureText: () {
                  ref.watch(obscureTextProvider.notifier).update(
                        (state) => !state,
                      );
                },
                hintText: "Password",
                textController: passwordController,
                obscureText: ref.watch(obscureTextProvider),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                toggleObscureText: () {
                  ref.watch(obscureTextProvider.notifier).update(
                        (state) => !state,
                      );
                },
                hintText: "Confirm Password",
                textController: passwordConfirmController,
                obscureText: ref.watch(obscureTextProvider),
              ),
              const SizedBox(height: 12),
              // Register button
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      style: const ButtonStyle(),
                      onPressed: () {
                        register();
                      },
                      child: const Text("Register"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already a user?",
                    style: TextStyle(),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.watch(registerOrLoginProvider.notifier).update(
                            (state) => !state,
                          );
                    },
                    child: const Text("Login"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
