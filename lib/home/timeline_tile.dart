import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:surphop/home/timeline_videos_page.dart';
import 'get_timeline_name.dart';

class TimelineTile extends StatelessWidget {
  final String timelineId;
  const TimelineTile({super.key, required this.timelineId});

  Function? deleteTimeline(BuildContext context) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return TimelineVideos(
            timelineId: timelineId,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
        child: Slidable(
          endActionPane: ActionPane(motion: const StretchMotion(), children: [
            SlidableAction(
              onPressed: deleteTimeline,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ]),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [GetTimelineName(timelineId: timelineId)]),
          ),
        ),
      ),
    );
  }
}
