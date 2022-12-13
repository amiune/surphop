import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surphop/videos/video_thumbnail_tile.dart';

import '../home/bottom_appbar.dart';
import '../timelines/get_timeline_name.dart';

class TimelineVideos extends StatefulWidget {
  final String timelineId;
  const TimelineVideos({super.key, required this.timelineId});

  @override
  State<TimelineVideos> createState() => _TimelineVideosState();
}

class _TimelineVideosState extends State<TimelineVideos> {
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _file;
  final ImagePicker _picker = ImagePicker();

  List<String> timelineVideoURLs = [];
  Future getTimelineVideos() async {
    timelineVideoURLs = [];
    await FirebaseFirestore.instance
        .collection('videos')
        .where('timelineId', isEqualTo: widget.timelineId)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              timelineVideoURLs.add(element['videoUrl']);
            }))));
  }

  Future uploadFile() async {
    if (_file == null) return;
    var fileExtension = _file!.path.substring(_file!.path.lastIndexOf('.'));
    try {
      final videoId = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance.ref().child(
          "users/${user.uid}/${widget.timelineId}/$videoId$fileExtension");
      await ref.putFile(_file!);
      String videoUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection("videos").add({
        'userId': user.uid,
        'timelineId': widget.timelineId,
        'videoUrl': videoUrl,
        'uploadDate': DateTime.now().toIso8601String()
      });
      setState(() {});
    } catch (e) {
      print('error occured');
    }
  }

  Future videoFromGallery() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _file = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: GetTimelineName(timelineId: widget.timelineId)),
      bottomNavigationBar: const MyBottomAppBar(),
      body: FutureBuilder(
          future: getTimelineVideos(),
          builder: (context, snapshot) {
            return CustomScrollView(slivers: <Widget>[
              SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    crossAxisCount: 3,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return VideoThumbnailTile(
                          videoUrl: timelineVideoURLs[index]);
                    },
                    childCount: timelineVideoURLs.length,
                  ))
            ]);
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: videoFromGallery,
        label: const Text("Add video"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
