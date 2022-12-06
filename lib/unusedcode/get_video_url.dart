import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetVideoURL extends StatelessWidget {
  final String videoId;
  const GetVideoURL({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    CollectionReference timelines =
        FirebaseFirestore.instance.collection('videos');

    return FutureBuilder<DocumentSnapshot>(
        future: timelines.doc(videoId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text(data['videoURL']);
          }
          return const Text("Loading...");
        });
  }
}
