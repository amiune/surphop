import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surphop/videos/video_thumbnail_tile.dart';

class TimelineVideos extends StatefulWidget {
  final String timelineId;
  final String timelineName;
  const TimelineVideos(
      {super.key, required this.timelineId, required this.timelineName});

  @override
  State<TimelineVideos> createState() => _TimelineVideosState();
}

class _TimelineVideosState extends State<TimelineVideos> {
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _file;
  final ImagePicker _picker = ImagePicker();

  List<String> timelineVideoIds = [];
  List<String> timelineVideoUserIds = [];
  List<String> timelineVideoURLs = [];
  Future getTimelineVideos() async {
    timelineVideoIds = [];
    timelineVideoUserIds = [];
    timelineVideoURLs = [];
    await FirebaseFirestore.instance
        .collection('videos')
        .where('timelineId', isEqualTo: widget.timelineId)
        .where('deleted', isEqualTo: false)
        .orderBy('uploadedDate', descending: true)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              timelineVideoIds.add(element.reference.id);
              timelineVideoUserIds.add(element['userId']);
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
      FirebaseFirestore.instance.collection("videos").add({
        'userId': user.uid,
        'timelineId': widget.timelineId,
        'videoUrl': videoUrl,
        'uploadedDate': DateTime.now().toIso8601String(),
        'deleted': false
      }).then((value) {
        setState(() {});
      });
      FirebaseFirestore.instance
          .collection("timelines")
          .doc(widget.timelineId)
          .update({
        'updatedDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      //print('error occured');
    }
  }

  Future videoFromGallery() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _file = File(pickedFile.path);
        uploadFile();
      } else {
        //print('No video selected.');
      }
    });
  }

  void deleteVideo(videoId) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Delete Video'),
            content: const Text("Are you sure?"),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Yes'),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection("videos")
                      .doc(videoId)
                      .update({'deleted': true}).then(
                    (_) {
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );

                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                },
              ),
              MaterialButton(
                color: Colors.grey,
                textColor: Colors.white,
                child: const Text('No'),
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
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
          title: Text(widget.timelineName)),
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
          future: getTimelineVideos(),
          builder: (context, snapshot) {
            if (timelineVideoURLs.isNotEmpty) {
              return CustomScrollView(slivers: <Widget>[
                SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      crossAxisCount: 3,
                      childAspectRatio: 0.55,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return VideoThumbnailTile(
                          videoId: timelineVideoIds[index],
                          videoUserId: timelineVideoUserIds[index],
                          videoUrl: timelineVideoURLs[index],
                          onDeletePressed: deleteVideo,
                        );
                      },
                      childCount: timelineVideoURLs.length,
                    ))
              ]);
            } else {
              return const Center(
                child: Text("There are no videos in this timeline yet"),
              );
            }
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
