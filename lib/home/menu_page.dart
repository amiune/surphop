import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/bottom_appbar.dart';

class MenuPage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MyBottomAppBar(),
      body: ListView(padding: EdgeInsets.zero, children: [
        SizedBox(
            height: 150.0,
            child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: user.displayName != ""
                    ? Text(user.displayName!)
                    : Text(user.email!))),
        ListTile(title: const Text("Verify Email"), onTap: () {}),
        ListTile(title: const Text("Profile"), onTap: () {}),
        ListTile(
            title: const Text('Sign Out'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            })
      ]),
    );
  }
}
