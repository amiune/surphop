import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:surphop/search/public_cachedvideo_page.dart';
import 'package:surphop/videocomments/cachedvideocomment_page.dart';

class NotificationTile extends StatelessWidget {
  final String notificationId;
  final String notificationText;
  final String notificationVideoId;
  final String? notificationVideoCommentId;
  final bool notificationViewed;
  final Function(String) deletePressed;
  const NotificationTile(
      {super.key,
      required this.notificationId,
      required this.notificationText,
      required this.notificationVideoId,
      required this.notificationVideoCommentId,
      required this.notificationViewed,
      required this.deletePressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (notificationVideoCommentId != null) {
          var videoComment = await FirebaseFirestore.instance
              .collection('videocomments')
              .doc(notificationVideoCommentId)
              .get();

          var videoFile = await DefaultCacheManager()
              .getSingleFile(videoComment["videoCommentUrl"]);

          // ignore: use_build_context_synchronously
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CachedVideoCommentPage(
              videoCommentId: videoComment.id,
              videoFile: videoFile,
              videoState: videoComment["approved"],
            );
          }));
        } else {
          var video = await FirebaseFirestore.instance
              .collection('videos')
              .doc(notificationVideoId)
              .get();

          var videoFile =
              await DefaultCacheManager().getSingleFile(video["videoUrl"]);

          // ignore: use_build_context_synchronously
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PublicCachedVideoPage(
              videoId: video.id,
              videoFile: videoFile,
              videoCreatorId: video["userId"],
            );
          }));
        }

        //MARK NOTIFICATION AS VIEWED
        FirebaseFirestore.instance
            .collection("notifications")
            .doc(notificationId)
            .update({
          'viewed': true,
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
        child: Slidable(
          endActionPane: ActionPane(motion: const StretchMotion(), children: [
            SlidableAction(
              onPressed: (context) {
                deletePressed(notificationId);
              },
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ]),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: notificationViewed ? Colors.grey[200] : Colors.blue[200],
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [Text(notificationText)]),
          ),
        ),
      ),
    );
  }
}