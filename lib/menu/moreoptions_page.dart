import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MoreOptionsPage extends StatefulWidget {
  const MoreOptionsPage({super.key});

  @override
  State<MoreOptionsPage> createState() => _MoreOptionsPageState();
}

class _MoreOptionsPageState extends State<MoreOptionsPage> {
  final user = FirebaseAuth.instance.currentUser!;

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
        ListTile(
            title: const Text('Sign Out'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            }),
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
