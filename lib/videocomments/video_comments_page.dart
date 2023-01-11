import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surphop/videocomments/cachedvideocomment_page.dart';
import 'package:surphop/videos/video_thumbnail_tile.dart';

class VideoCommentsPage extends StatefulWidget {
  final String videoId;
  const VideoCommentsPage({super.key, required this.videoId});

  @override
  State<VideoCommentsPage> createState() => _VideoCommentsPageState();
}

class _VideoCommentsPageState extends State<VideoCommentsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _file;
  final ImagePicker _picker = ImagePicker();

  List<String> videoCommentIds = [];
  List<String> videoCommentUserIds = [];
  List<String> videoCommentURLs = [];
  Future getVideoComments() async {
    videoCommentIds = [];
    videoCommentUserIds = [];
    videoCommentURLs = [];
    await FirebaseFirestore.instance
        .collection('videocomments')
        .where('videoId', isEqualTo: widget.videoId)
        .where('approved', isGreaterThanOrEqualTo: 0)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              videoCommentIds.add(element.reference.id);
              videoCommentUserIds.add(element['userId']);
              videoCommentURLs.add(element['videoCommentUrl']);
            }))));
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

      final videoCommentId = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance.ref().child(
          "videocomments/${widget.videoId}/${user.uid}/$videoCommentId$fileExtension");
      await ref.putFile(_file!);
      String videoUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection("videocomments").add({
        'videoId': widget.videoId,
        'userId': user.uid,
        'videoCommentUrl': videoUrl,
        'uploadedDate': DateTime.now().toIso8601String(),
        'approved': 0,
        'reportedText': ""
      });
      setState(() {});
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
            if (videoCommentURLs.isNotEmpty) {
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
                                .getSingleFile(videoCommentURLs[index]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return CachedVideoCommentPage(
                                          videoId: videoCommentIds[index],
                                          videoFile: snapshot.data!,
                                        );
                                      }));
                                    },
                                    child: VideoThumbnailTile(
                                      videoId: videoCommentIds[index],
                                      videoUrl: videoCommentURLs[index],
                                      videoFile: snapshot.data!,
                                      onDeletePressed: (_) {},
                                    ));
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            });
                      },
                      childCount: videoCommentURLs.length,
                    ))
              ]);
            } else {
              return const Center(
                child: Text("There are no comments for this video yet"),
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
