import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/search/public_timeline_tile.dart';
import 'package:surphop/search/search_delegate.dart';

class FollowingTimelines extends StatefulWidget {
  const FollowingTimelines({super.key});

  @override
  State<FollowingTimelines> createState() => _FollowingTimelinesState();
}

class _FollowingTimelinesState extends State<FollowingTimelines> {
  final user = FirebaseAuth.instance.currentUser!;
  String? timelineNameText;

  List<String> timelinesIds = [];
  List<String> timelinesNames = [];
  Future getMyTimelines() async {
    timelinesIds = [];
    timelinesNames = [];
    await FirebaseFirestore.instance
        .collection('followingtimelines')
        .where('userId', isEqualTo: user.uid.toString())
        .orderBy('timelineName', descending: false)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              timelinesIds.add(element["timelineId"]);
              timelinesNames.add(element["timelineName"]);
            }))));
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
            future: getMyTimelines(),
            builder: (context, snapshot) {
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
                      return PublicTimelineTile(
                        timelineId: timelinesIds[index],
                        timelineName: timelinesNames[index],
                      );
                    });
              }
            }));
  }
}
