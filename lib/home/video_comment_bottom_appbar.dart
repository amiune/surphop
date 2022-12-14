import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/menu_page.dart';

class VideoCommentBottomAppBar extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  final String videoId;
  final String videoUserId;
  VideoCommentBottomAppBar({
    super.key,
    required this.videoId,
    required this.videoUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.blue,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Navigator.canPop(context)
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back_ios))
                  : const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MenuPage();
                }));
              },
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Approve',
              icon: const Icon(Icons.thumb_up),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Disaprove',
              icon: const Icon(Icons.thumb_down),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Report',
              icon: const Icon(Icons.warning),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
