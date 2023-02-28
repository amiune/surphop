import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surphop/videocomments/cachedvideocomment_page.dart';
import 'package:surphop/videos/video_thumbnail_tile.dart';

class SortableVideoComment {
  String videoCommentId;
  String videoCommentUserId;
  String videoCommentURL;
  int videoState;
  DateTime videoCommentUploadedDate;

  SortableVideoComment(this.videoCommentId, this.videoCommentUserId,
      this.videoCommentURL, this.videoState, this.videoCommentUploadedDate);
}

class VideoCommentsPage extends StatefulWidget {
  final String videoId;
  final String videoCreatorId;
  const VideoCommentsPage({
    super.key,
    required this.videoId,
    required this.videoCreatorId,
  });

  @override
  State<VideoCommentsPage> createState() => _VideoCommentsPageState();
}

class _VideoCommentsPageState extends State<VideoCommentsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _file;
  final ImagePicker _picker = ImagePicker();

  List<SortableVideoComment> videoComments = [];

  Future getVideoComments() async {
    videoComments = [];
    var videoCommentsRef = await FirebaseFirestore.instance
        .collection('videocomments')
        .where('videoId', isEqualTo: widget.videoId)
        .where('approved', isGreaterThanOrEqualTo: 0)
        .get();

    for (var element in videoCommentsRef.docs) {
      videoComments.add(SortableVideoComment(
          element.reference.id,
          element['userId'],
          element['videoCommentUrl'],
          element['approved'],
          DateTime.parse(element['uploadedDate'])));
    }

    videoComments.sort((a, b) =>
        b.videoCommentUploadedDate.compareTo(a.videoCommentUploadedDate));
  }

  Future uploadFile() async {
    if (_file == null) return;

    try {
      const snackBar = SnackBar(content: Text('Uploading...'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      var fileExtension = _file!.path.substring(_file!.path.lastIndexOf('.'));
      int sizeInBytes = _file!.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 100) {
        throw Exception("File is to big. Needs to be less than 100MB");
      }

      var today = DateTime.now();
      final videoCommentId = today.millisecondsSinceEpoch;
      var path =
          "videocomments/${widget.videoId}/${user.uid}/$videoCommentId$fileExtension";
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(_file!);
      String videoUrl = await ref.getDownloadURL();
      var uploadedVideoCommentReference =
          await FirebaseFirestore.instance.collection("videocomments").add({
        'videoId': widget.videoId,
        'userId': user.uid,
        'videoCommentUrl': videoUrl,
        'uploadedDate': today.toIso8601String(),
        'approved': 0,
        'reportedText': "",
        'path': path
      });
      setState(() {});

      //---------------- ADD NOTIFICATION START ----------------
      //REPLACE THIS WITH FIREBASE FUNCTIONS
      //Notify the video creator
      List<String> commentersList = [];
      if (user.uid != widget.videoCreatorId) {
        commentersList.add(widget.videoCreatorId);
      }
      //Notify all users that commented the video
      var commentsRef = await FirebaseFirestore.instance
          .collection('videocomments')
          .where('videoId', isEqualTo: widget.videoId)
          .get();
      for (var element in commentsRef.docs) {
        if (user.uid != element["userId"]) {
          commentersList.add(element["userId"]);
        }
      }

      String? commenterUserName = user.displayName;
      if (commenterUserName == null || commenterUserName == "") {
        commenterUserName = user.email;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (var commenter in commentersList) {
        var notificationsRef =
            FirebaseFirestore.instance.collection("notifications").doc();
        batch.set(notificationsRef, {
          'forUserId': commenter,
          'fromUserId': user.uid,
          'videoId': widget.videoId,
          'videoCommentId': uploadedVideoCommentReference.id,
          'notificationDate': DateTime.now().toIso8601String(),
          'viewed': false,
          'text': "There is a new video comment from $commenterUserName"
        });
        batch.commit();
      }
      //---------------- ADD NOTIFICATION END ----------------

    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("You don't have permissions"),
              content: const Text(
                  "Please contact the admin to become a teacher and be able to comment other videos"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text("Video Comments")),
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
          future: getVideoComments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (videoComments.isNotEmpty) {
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
                              future: DefaultCacheManager().getSingleFile(
                                  videoComments[index].videoCommentURL),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CachedVideoCommentPage(
                                            videoCommentId: videoComments[index]
                                                .videoCommentId,
                                            videoFile: snapshot.data!,
                                            videoState:
                                                videoComments[index].videoState,
                                          );
                                        }));
                                      },
                                      child: VideoThumbnailTile(
                                        videoId:
                                            videoComments[index].videoCommentId,
                                        videoUrl: videoComments[index]
                                            .videoCommentURL,
                                        videoUploadedDate: videoComments[index]
                                            .videoCommentUploadedDate,
                                        videoFile: snapshot.data!,
                                        onDeletePressed: (_) {},
                                      ));
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              });
                        },
                        childCount: videoComments.length,
                      ))
                ]);
              } else {
                return const Center(
                  child: Text("There are no comments for this video yet"),
                );
              }
            } else {
              return const Center(
                child: Text("Loading video comments..."),
              );
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: videoFromGallery,
        label: const Text("Add video comment"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
