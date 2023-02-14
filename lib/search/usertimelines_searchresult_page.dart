import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:surphop/search/public_timeline_tile.dart';

class UserTimelines extends StatefulWidget {
  final String userEmail;
  final String userId;
  const UserTimelines(
      {super.key, required this.userEmail, required this.userId});

  @override
  State<UserTimelines> createState() => _UserTimelinesState();
}

class _UserTimelinesState extends State<UserTimelines> {
  List<String> timelinesIds = [];
  List<String> timelinesNames = [];
  Future getTimelines() async {
    timelinesIds = [];
    timelinesNames = [];
    var timelinesRef = await FirebaseFirestore.instance
        .collection('timelines')
        .where('userId', isEqualTo: widget.userId)
        .orderBy('updatedDate', descending: true)
        .get();

    for (var element in timelinesRef.docs) {
      timelinesIds.add(element.reference.id);
      timelinesNames.add(element["timelineName"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text("${widget.userEmail} Timelines")),
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
        body: FutureBuilder(
            future: getTimelines(),
            builder: (context, snapshot) {
              return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 150),
                  itemCount: timelinesIds.length,
                  itemBuilder: (context, index) {
                    return PublicTimelineTile(
                      timelineId: timelinesIds[index],
                      timelineName: timelinesNames[index],
                    );
                  });
            }));
  }
}
