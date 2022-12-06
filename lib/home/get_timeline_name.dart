import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetTimelineName extends StatelessWidget {
  final String timelineId;
  const GetTimelineName({super.key, required this.timelineId});

  @override
  Widget build(BuildContext context) {
    CollectionReference timelines =
        FirebaseFirestore.instance.collection('timelines');

    return FutureBuilder<DocumentSnapshot>(
        future: timelines.doc(timelineId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text(data['timelineName']);
          }
          return const Text("Loading...");
        });
  }
}
