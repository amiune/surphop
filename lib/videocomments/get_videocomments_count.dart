import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetVideoCommentsCount extends StatelessWidget {
  final String videoId;
  const GetVideoCommentsCount({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    CollectionReference videos =
        FirebaseFirestore.instance.collection('videocomments');

    return FutureBuilder<QuerySnapshot>(
        future: videos.where('videoId', isEqualTo: videoId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var docs = snapshot.data!.docs;
            var newComments = 0;
            for (var element in docs) {
              if (element["approved"] == 0) newComments++;
            }
            return Text("Comments ${docs.length} ($newComments)");
          }
          return const Text("Loading...");
        });
  }
}
