import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LOGIN"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.key),
                  hintText: "Enter your email",
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
                controller: _password,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder())),
            FilledButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email, password: password);
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'wrong-password') {
                      await showErrorDialog(
                        context,
                        e.code.toUpperCase(),
                      );
                    } else if (e.code == 'user-not-found') {
                      await showErrorDialog(
                        context,
                        e.code.toUpperCase(),
                      );
                    } else {
                      await showErrorDialog(
                        context,
                        e.code.toUpperCase(),
                      );
                    }
                  } catch (e) {
                    await showErrorDialog(context, e.toString());
                  }
                },
                child: const Text("Login")),
            FilledButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                },
                child: const Text("not registered yet? register!!!"))
          ],
        ),
      ),
    );
  }
}
