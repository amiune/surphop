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

  List<String> timelinesIds = [];
  Future getMyTimelines() async {
    timelinesIds = [];
    await FirebaseFirestore.instance
        .collection('timelines')
        .where('userId', isEqualTo: user.uid.toString())
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              timelinesIds.add(element.reference.id);
            }))));
  }

  void createNewTimeline() async {
    showDialog(
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
                    setState(() {});
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
        appBar: AppBar(
          title: Text(
            user.email!,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  //Navigator.push(context, MaterialPageRoute(builder: (context) {return VideoApp();}));
                },
                child: const Icon(Icons.logout))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTimeline,
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
            future: getMyTimelines(),
            builder: (context, snapshot) {
              return ListView.builder(
                  itemCount: timelinesIds.length,
                  itemBuilder: (context, index) {
                    return TimelineTile(timelineId: timelinesIds[index]);
                  });
            }));
  }
}
