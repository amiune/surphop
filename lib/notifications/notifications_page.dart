import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/notifications/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final user = FirebaseAuth.instance.currentUser!;

  List<String> notificationIds = [];
  List<String> notificationTexts = [];
  Future getMyTimelines() async {
    notificationIds = [];
    notificationTexts = [];
    await FirebaseFirestore.instance
        .collection('notifications')
        .where('forUserId', isEqualTo: user.uid.toString())
        .orderBy('notificationDate', descending: true)
        .get()
        .then(((snapshot) => snapshot.docs.forEach(((element) {
              notificationIds.add(element.reference.id);
              notificationTexts.add(element["text"]);
            }))));
  }

  Future<void> deleteNotification(timelineId) async {
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(timelineId)
        .delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text("Notifications")),
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
            future: getMyTimelines(),
            builder: (context, snapshot) {
              return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 150),
                  itemCount: notificationIds.length,
                  itemBuilder: (context, index) {
                    return NotificationTile(
                      notificationId: notificationIds[index],
                      notificationText: notificationTexts[index],
                      deletePressed: deleteNotification,
                    );
                  });
            }));
  }
}
