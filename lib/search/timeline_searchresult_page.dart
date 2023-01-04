import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:surphop/search/public_cachedvideo_page.dart';
import 'package:surphop/videos/video_thumbnail_tile.dart';

class PublicTimelineVideos extends StatefulWidget {
  final String timelineId;
  final String timelineName;
  const PublicTimelineVideos(
      {super.key, required this.timelineId, required this.timelineName});

  @override
  State<PublicTimelineVideos> createState() => _PublicTimelineVideosState();
}

class _PublicTimelineVideosState extends State<PublicTimelineVideos> {
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseStorage storage = FirebaseStorage.instance;

  List<String> timelineVideoIds = [];
  List<String> timelineVideoURLs = [];
  Future getTimelineVideos() async {
    timelineVideoIds = [];
    timelineVideoURLs = [];
    await FirebaseFirestore.instance
        .collection('videos')
        .where('timelineId', isEqualTo: widget.timelineId)
        .where('deleted', isEqualTo: false)
        .orderBy('uploadedDate', descending: true)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              timelineVideoIds.add(element.reference.id);
              timelineVideoURLs.add(element['videoUrl']);
            }))));
  }

  Future<void> followTimeline() async {
    try {
      var currentTime = DateTime.now().toIso8601String();
      await FirebaseFirestore.instance.collection("followingtimelines").add({
        'userId': user.uid,
        'timelineId': widget.timelineId,
        'timelineName': widget.timelineName,
        'creationDate': currentTime,
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Following!'),
              content: const Text("You are now following this timeline"),
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
    } catch (_) {}
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: followTimeline,
        label: const Text("Follow timeline"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                                        return PublicCachedVideoPage(
                                          videoId: timelineVideoIds[index],
                                          videoFile: snapshot.data!,
                                        );
                                      }));
                                    },
                                    child: VideoThumbnailTile(
                                      videoId: timelineVideoIds[index],
                                      videoUrl: timelineVideoURLs[index],
                                      videoFile: snapshot.data!,
                                      onDeletePressed: ((p0) {}),
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
    );
  }
}
