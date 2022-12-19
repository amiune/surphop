import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:surphop/videos/timeline_videos_page.dart';

class TimelineTile extends StatelessWidget {
  final String timelineId;
  final String timelineName;
  final Function(String, String) deletePressed;
  const TimelineTile(
      {super.key,
      required this.timelineId,
      required this.timelineName,
      required this.deletePressed});

  @override
  Widget build(BuildContext context) {
    List<String> timelineVideoIds = [];
    List<String> timelineVideoUserIds = [];
    List<String> timelineVideoURLs = [];
    Future getTimelineVideos() async {
      timelineVideoIds = [];
      timelineVideoUserIds = [];
      timelineVideoURLs = [];
      await FirebaseFirestore.instance
          .collection('videos')
          .where('timelineId', isEqualTo: timelineId)
          .where('deleted', isEqualTo: false)
          .orderBy('uploadedDate', descending: true)
          .get()
          .then(((snapshot) => snapshot.docs.forEach(((element) {
                timelineVideoIds.add(element.reference.id);
                timelineVideoUserIds.add(element['userId']);
                timelineVideoURLs.add(element['videoUrl']);
              }))));
    }

    return FutureBuilder(
      future: getTimelineVideos(),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TimelineVideos(
                timelineId: timelineId,
                timelineName: timelineName,
                timelineVideoIds: timelineVideoIds,
                timelineVideoUserIds: timelineVideoUserIds,
                timelineVideoURLs: timelineVideoURLs,
              );
            }));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
            child: Slidable(
              endActionPane:
                  ActionPane(motion: const StretchMotion(), children: [
                SlidableAction(
                  onPressed: (context) {
                    deletePressed(timelineId, timelineName);
                  },
                  icon: Icons.delete,
                  backgroundColor: Colors.red.shade300,
                  borderRadius: BorderRadius.circular(12),
                )
              ]),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [Text(timelineName)]),
              ),
            ),
          ),
        );
      },
    );
  }
}
