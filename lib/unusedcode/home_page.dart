import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/mytimelines_page.dart';
import 'package:surphop/unusedcode/video_upload.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  String? timelineNameText;
  final _timelineNameController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Learning Timeline'),
            content: TextField(
              controller: _timelineNameController,
              decoration: const InputDecoration(hintText: "Timeline Name"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () async {
                  if (_timelineNameController.text.trim() != "") {
                    await FirebaseFirestore.instance
                        .collection("timelines")
                        .add({
                      'userId': user.uid,
                      'timelineName': _timelineNameController.text.trim(),
                      'creationDate': DateTime.now().toIso8601String()
                    });
                  }

                  _timelineNameController.text = "";

                  if (!mounted) return;
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
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Signed In as ${user.email}"),
      const SizedBox(height: 10),
      MaterialButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
        },
        color: Colors.green[200],
        child: const Text("Sign Out"),
      ),
      const SizedBox(height: 10),
      MaterialButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        color: Colors.green[200],
        child: const Text("Create Timeline"),
      ),
      const SizedBox(height: 10),
      MaterialButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const VideoUpload(timelineId: 'xx');
          }));
        },
        color: Colors.green[200],
        child: const Text("Upload Video"),
      ),
      MaterialButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const MyTimelines();
          }));
        },
        color: Colors.green[200],
        child: const Text("My Timelines"),
      )
    ])));
  }
}
