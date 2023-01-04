import 'package:flutter/material.dart';
import 'package:surphop/search/timeline_searchresult_page.dart';

class PublicTimelineTile extends StatelessWidget {
  final String timelineId;
  final String timelineName;
  const PublicTimelineTile({
    super.key,
    required this.timelineId,
    required this.timelineName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PublicTimelineVideos(
            timelineId: timelineId,
            timelineName: timelineName,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.blue[200], borderRadius: BorderRadius.circular(12)),
          child: Row(children: [Text(timelineName)]),
        ),
      ),
    );
  }
}
