import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:surphop/search/timeline_searchresult_page.dart';

class FollowingTimelineTile extends StatelessWidget {
  final String followingTimelineId;
  final String followingTimelineName;
  final String timelineId;
  final Function(String, String) editPressed;
  final Function(String, String) deletePressed;
  const FollowingTimelineTile(
      {super.key,
      required this.followingTimelineId,
      required this.followingTimelineName,
      required this.timelineId,
      required this.editPressed,
      required this.deletePressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PublicTimelineVideos(
            timelineId: timelineId,
            timelineName: followingTimelineName,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
        child: Slidable(
          endActionPane: ActionPane(motion: const StretchMotion(), children: [
            SlidableAction(
              onPressed: (context) {
                editPressed(followingTimelineId, followingTimelineName);
              },
              icon: Icons.create,
              backgroundColor: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) {
                deletePressed(followingTimelineId, followingTimelineName);
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
            child: Row(children: [Text(followingTimelineName)]),
          ),
        ),
      ),
    );
  }
}
