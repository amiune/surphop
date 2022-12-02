import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TimelineTile extends StatelessWidget {
  final String timelineName;
  const TimelineTile({super.key, required this.timelineName});

  Function? deleteTimeline(BuildContext context) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          child: Row(children: [Text(timelineName)]),
        ),
      ),
    );
  }
}
