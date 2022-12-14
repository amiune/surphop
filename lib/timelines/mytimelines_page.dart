import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/bottom_appbar.dart';
import 'package:surphop/timelines/timeline_tile.dart';

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
  List<String> timelinesNames = [];
  Future getMyTimelines() async {
    timelinesIds = [];
    timelinesNames = [];
    await FirebaseFirestore.instance
        .collection('timelines')
        .where('userId', isEqualTo: user.uid.toString())
        .orderBy('updatedDate', descending: true)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              timelinesIds.add(element.reference.id);
              timelinesNames.add(element["timelineName"]);
            }))));
  }

  void deleteTimeline(timelineId, timelineName) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Learning Timeline?'),
            content: Text(timelineName),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Yes'),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection("timelines")
                      .doc(timelineId)
                      .delete()
                      .then((_) {
                    setState(() {});
                  });

                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.grey,
                textColor: Colors.white,
                child: const Text('No'),
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
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
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () async {
                  if (_timelineNameController.text.trim() != "") {
                    var currentTime = DateTime.now().toIso8601String();
                    await FirebaseFirestore.instance
                        .collection("timelines")
                        .add({
                      'userId': user.uid,
                      'timelineName': _timelineNameController.text.trim(),
                      'creationDate': currentTime,
                      'updatedDate': currentTime,
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
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text("My Timelines")),
        bottomNavigationBar: const MenuBottomAppBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: createNewTimeline,
          label: const Text("Add timeline"),
          icon: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: FutureBuilder(
            future: getMyTimelines(),
            builder: (context, snapshot) {
              return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 150),
                  itemCount: timelinesIds.length,
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      timelineId: timelinesIds[index],
                      timelineName: timelinesNames[index],
                      deletePressed: deleteTimeline,
                    );
                  });
            }));
  }
}
