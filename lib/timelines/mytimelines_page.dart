import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/menu/menu_page.dart';
import 'package:surphop/notifications/notifications_page.dart';
import 'package:surphop/timelines/following_timelines_page.dart';
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
    var timelinesRef = await FirebaseFirestore.instance
        .collection('timelines')
        .where('userId', isEqualTo: user.uid.toString())
        .orderBy('updatedDate', descending: true)
        .get();

    for (var element in timelinesRef.docs) {
      timelinesIds.add(element.reference.id);
      timelinesNames.add(element["timelineName"]);
    }
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
    _timelineNameController.text = "";
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
                      'tags': _timelineNameController.text
                          .trim()
                          .toLowerCase()
                          .split(" "),
                      'creationDate': currentTime,
                      'updatedDate': currentTime,
                      "public": false
                    });
                    setState(() {});
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void editTimeline(timelineId, timelineName) async {
    _timelineNameController.text = timelineName;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Timeline'),
            content: TextField(
              controller: _timelineNameController,
              decoration: InputDecoration(hintText: timelineName),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () async {
                  if (_timelineNameController.text.trim() != "") {
                    await FirebaseFirestore.instance
                        .collection("timelines")
                        .doc(timelineId)
                        .update({
                      'timelineName': _timelineNameController.text.trim(),
                      'tags': _timelineNameController.text
                          .trim()
                          .toLowerCase()
                          .split(" "),
                    });
                    setState(() {});
                  }

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
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (newContext) {
                      return const MenuPage();
                    }));
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Following',
                  icon: const Icon(Icons.people_alt),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (newContext) {
                      return const FollowingTimelinesPage();
                    }));
                  },
                ),
                IconButton(
                  tooltip: 'Notifications',
                  icon: const Icon(Icons.notifications_rounded),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (newContext) {
                      return const NotificationsPage();
                    }));
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: createNewTimeline,
          label: const Text("Add timeline"),
          icon: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: FutureBuilder(
            future: getMyTimelines(),
            builder: (context, snapshot) {
              if (timelinesIds.isNotEmpty) {
                return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150),
                    itemCount: timelinesIds.length,
                    itemBuilder: (context, index) {
                      return TimelineTile(
                        timelineId: timelinesIds[index],
                        timelineName: timelinesNames[index],
                        editPressed: editTimeline,
                        deletePressed: deleteTimeline,
                      );
                    });
              } else {
                return const Center(
                  child:
                      Text("Click Add timeline to create your first timeline"),
                );
              }
            }));
  }
}
