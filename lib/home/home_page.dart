import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/video_upload.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Signed In as ${user.email}"),
      MaterialButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
        },
        color: Colors.green[200],
        child: const Text("Sign Out"),
      ),
      const SizedBox(height: 30),
      MaterialButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const VideoUpload();
          }));
        },
        color: Colors.green[200],
        child: const Text("Upload Video"),
      )
    ])));
  }
}
