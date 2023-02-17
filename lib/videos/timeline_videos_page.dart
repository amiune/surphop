import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surphop/videos/cachedvideo_page.dart';
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
  List<String> timelineVideoURLs = [];
  List<DateTime> timelineVideoUploadedDate = [];
  List<String> timelineVideoCreatorId = [];
  Future getTimelineVideos() async {
    timelineVideoIds = [];
    timelineVideoURLs = [];
    timelineVideoUploadedDate = [];
    timelineVideoCreatorId = [];
    var videosRef = await FirebaseFirestore.instance
        .collection('videos')
        .where('timelineId', isEqualTo: widget.timelineId)
        .where('deleted', isEqualTo: false)
        .orderBy('uploadedDate', descending: true)
        .get();

    for (var element in videosRef.docs) {
      timelineVideoIds.add(element.reference.id);
      timelineVideoURLs.add(element['videoUrl']);
      timelineVideoUploadedDate.add(DateTime.parse(element['uploadedDate']));
      timelineVideoCreatorId.add(element['userId']);
    }
  }

  Future uploadFile() async {
    if (_file == null) return;

    try {
      var fileExtension = _file!.path.substring(_file!.path.lastIndexOf('.'));
      int sizeInBytes = _file!.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 100) {
        throw Exception("File is to big. Needs to be less than 100MB");
      }

      var today = DateTime.now();
      final videoId = today.millisecondsSinceEpoch;
      var path =
          "users/${user.uid}/${widget.timelineId}/$videoId$fileExtension";
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(_file!);
      String videoUrl = await ref.getDownloadURL();
      var uploadedVideoReference =
          await FirebaseFirestore.instance.collection("videos").add({
        'userId': user.uid,
        'timelineId': widget.timelineId,
        'videoUrl': videoUrl,
        'uploadedDate': today.toIso8601String(),
        'deleted': false,
        'path': path
      });

      //---------------- ADD NOTIFICATIONS START ----------------
      //REPLACE THIS WITH FIREBASE FUNCTIONS
      //GET ALL FOLLOWING widget.timelineId AND ADD NOTIFICATION FOR EACH
      List<String> followersList = [];
      var followersRef = await FirebaseFirestore.instance
          .collection('followingtimelines')
          .where('timelineId', isEqualTo: widget.timelineId)
          .get();
      for (var element in followersRef.docs) {
        followersList.add(element["userId"]);
      }

      String? userName = user.displayName;
      if (userName == null || userName == "") {
        userName = user.email;
      }
      final batch = FirebaseFirestore.instance.batch();
      for (var follower in followersList) {
        if (user.uid != follower) {
          var notificationsRef =
              FirebaseFirestore.instance.collection("notifications").doc();
          batch.set(notificationsRef, {
            'forUserId': follower,
            'fromUserId': user.uid,
            'timelineId': widget.timelineId,
            'videoId': uploadedVideoReference.id,
            'notificationDate': DateTime.now().toIso8601String(),
            'viewed': false,
            'text':
                "$userName uploaded a new video in timeline ${widget.timelineName}"
          });
        }
      }
      batch.commit();
      //---------------- ADD NOTIFICATIONS END ----------------

      setState(() {});
      //UPDATE TIMELINE UPDATED DATE
      FirebaseFirestore.instance
          .collection("timelines")
          .doc(widget.timelineId)
          .update({
        'updatedDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error!'),
              content: Text(e.toString()),
              actions: <Widget>[
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
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
          child: Row(children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            /*
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.public_off),
              tooltip: "Public",
              onPressed: () {},
            ),
            */
          ]),
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
                        return FutureBuilder(
                            future: DefaultCacheManager()
                                .getSingleFile(timelineVideoURLs[index]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return CachedVideoPage(
                                          videoId: timelineVideoIds[index],
                                          videoFile: snapshot.data!,
                                          onDeletePressed: deleteVideo,
                                          videoCreatorId:
                                              timelineVideoCreatorId[index],
                                        );
                                      }));
                                    },
                                    child: VideoThumbnailTile(
                                      videoId: timelineVideoIds[index],
                                      videoUrl: timelineVideoURLs[index],
                                      videoUploadedDate:
                                          timelineVideoUploadedDate[index],
                                      videoFile: snapshot.data!,
                                      onDeletePressed: deleteVideo,
                                    ));
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            });
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
