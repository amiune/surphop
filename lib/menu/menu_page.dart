import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/menu/moreoptions_page.dart';
import 'package:surphop/notifications/notifications_page.dart';
import 'package:surphop/search/search_delegate.dart';
import 'package:surphop/timelines/following_timelines_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final user = FirebaseAuth.instance.currentUser!;

  void emailVerificationSent(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Email Verification Sent'),
            content: const Text("Check your email inbox"),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: ListView(padding: EdgeInsets.zero, children: [
        SizedBox(
            height: 150.0,
            child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: user.displayName != null && user.displayName != ""
                    ? Text(user.displayName!)
                    : Text(user.email!))),
        if (user.emailVerified == false)
          ListTile(
              title: const Text("Verify Email"),
              onTap: () {
                user.sendEmailVerification().then((value) {
                  emailVerificationSent(context);
                });
              }),
        ListTile(
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (newContext) {
                return const NotificationsPage();
              }));
            }),
        ListTile(
            title: const Text("Following"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (newContext) {
                return const FollowingTimelinesPage();
              }));
            }),
        ListTile(
            title: const Text("Search"),
            onTap: () async {
              await showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                  query: "");
            }),
        ListTile(
            title: const Text('Sign Out'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            }),
        ListTile(
            title: const Text('More options...'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (newContext) {
                return const MoreOptionsPage();
              }));
            }),
      ]),
    );
  }
}
