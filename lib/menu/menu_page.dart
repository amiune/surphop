import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  void pleaseSignOut(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please sign out'),
            content: const Text(
                "Your videos were scheduled for deletion but you need to Sign Out and Sign In and click Delete Account again to delete your account completely."),
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

  void deleteAccount(context) {
    showDialog(
        context: context,
        builder: (newcontext) {
          return AlertDialog(
            title: const Text('Delete account?'),
            content: const Text("Are you sure?"),
            actions: <Widget>[
              MaterialButton(
                color: Colors.grey,
                textColor: Colors.white,
                child: const Text('yes'),
                onPressed: () async {
                  var batch = FirebaseFirestore.instance.batch();
                  await FirebaseFirestore.instance
                      .collection('videos')
                      .where('userId', isEqualTo: user.uid)
                      .get()
                      .then(((snapshot) => snapshot.docs.forEach(((element) {
                            batch.update(element.reference, {'deleted': true});
                          }))));
                  batch.commit().then((value) {
                    user.delete().catchError((value) {
                      pleaseSignOut(context);
                    });
                  });
                  if (mounted) Navigator.pop(newcontext);
                },
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text("NO, don't delete account"),
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
            title: const Text("Following"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (newContext) {
                return const FollowingTimelines();
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
        const ListTile(),
        const ListTile(),
        const ListTile(),
        const ListTile(),
        ListTile(
            title: const Text(
              'Delete Account',
            ),
            onTap: () {
              deleteAccount(context);
            })
      ]),
    );
  }
}
