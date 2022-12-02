import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/timeline_tile.dart';

class MyTimelines extends StatefulWidget {
  const MyTimelines({super.key});

  @override
  State<MyTimelines> createState() => _MyTimelinesState();
}

class _MyTimelinesState extends State<MyTimelines> {
  final user = FirebaseAuth.instance.currentUser!;
  String? timelineNameText;
  final _timelineNameController = TextEditingController();

  void createNewTimeline() async {
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
        appBar: AppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTimeline,
          child: const Icon(Icons.add),
        ),
        body: ListView(
          children: const [
            TimelineTile(
              timelineName: "Latte Art",
            ),
            TimelineTile(timelineName: "Guitarra"),
          ],
        ));
  }
}
