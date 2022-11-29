import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'forgotpassword_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future signIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 100),
            const SizedBox(height: 75),
            const SizedBox(height: 25),
            Text("Hello Again", style: GoogleFonts.bebasNeue(fontSize: 52)),
            //const Text("Hello Again!"),
            const SizedBox(height: 10),
            const Text("Welcome back!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Email"),
                        )))),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: "Password"),
                        )))),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ForgotPasswordPage();
                      }));
                    },
                    child: const Text("Forgot Password?",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.green[200],
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        )))),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Not registered? ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: widget.showRegisterPage,
                  child: const Text("Register Now",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        )))));
  }
}
