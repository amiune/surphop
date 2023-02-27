import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/search/search_delegate.dart';
import 'package:surphop/timelines/folowingtimeline_tile.dart';

class FollowingTimelinesPage extends StatefulWidget {
  const FollowingTimelinesPage({super.key});

  @override
  State<FollowingTimelinesPage> createState() => _FollowingTimelinesPageState();
}

class _FollowingTimelinesPageState extends State<FollowingTimelinesPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? timelineNameText;
  final _timelineNameController = TextEditingController();

  List<String> followingTimelinesIds = [];
  List<String> followingTimelinesNames = [];
  List<String> timelinesIds = [];
  Future getMyFollowingTimelines() async {
    followingTimelinesIds = [];
    followingTimelinesNames = [];
    timelinesIds = [];
    var followingTimelinesRef = await FirebaseFirestore.instance
        .collection('followingtimelines')
        .where('userId', isEqualTo: user.uid.toString())
        .orderBy('timelineName', descending: false)
        .get();

    for (var element in followingTimelinesRef.docs) {
      followingTimelinesIds.add(element.reference.id);
      followingTimelinesNames.add(element["timelineName"]);
      timelinesIds.add(element["timelineId"]);
    }
  }

  void deleteFollowingTimeline(timelineId, timelineName) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Stop Following Timeline?'),
            content: Text(timelineName),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Yes'),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection("followingtimelines")
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

  void editFollowingTimeline(timelineId, timelineName) async {
    _timelineNameController.text = timelineName;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Name'),
            content: TextField(
              controller: _timelineNameController,
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () async {
                  if (_timelineNameController.text.trim() != "") {
                    await FirebaseFirestore.instance
                        .collection("followingtimelines")
                        .doc(timelineId)
                        .update({
                      'timelineName': _timelineNameController.text.trim(),
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
            title: const Text("Following Timelines")),
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
                const Spacer(),
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    await showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(),
                            query: "")
                        .then((value) {
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder(
            future: getMyFollowingTimelines(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (timelinesIds.isEmpty) {
                  return const Center(
                    child: Text(
                        "You are not following any timelines \n click the search icon to find one"),
                  );
                } else {
                  return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 150),
                      itemCount: timelinesIds.length,
                      itemBuilder: (context, index) {
                        return FollowingTimelineTile(
                          followingTimelineId: followingTimelinesIds[index],
                          followingTimelineName: followingTimelinesNames[index],
                          timelineId: timelinesIds[index],
                          editPressed: editFollowingTimeline,
                          deletePressed: deleteFollowingTimeline,
                        );
                      });
                }
              } else {
                return const Center(
                  child: Text("Loading timelines..."),
                );
              }
            }));
  }
}
