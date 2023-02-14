import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationTile extends StatelessWidget {
  final String notificationId;
  final String notificationText;
  final Function(String) deletePressed;
  const NotificationTile(
      {super.key,
      required this.notificationId,
      required this.notificationText,
      required this.deletePressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //TODO: SEND TO CACHED VIDEO OR CACHED VIDEOCOMMENT PAGE
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
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [Text(notificationText)]),
          ),
        ),
      ),
    );
  }
}
