import 'package:flutter/material.dart';
import 'package:surphop/home/menu_page.dart';

class VideoBottomAppBar extends StatelessWidget {
  final String videoId;
  final Function() onDeletePressed;
  const VideoBottomAppBar(
      {super.key, required this.videoId, required this.onDeletePressed});

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
              tooltip: 'Delete',
              icon: const Icon(Icons.delete),
              onPressed: () {
                onDeletePressed();
              },
            ),
          ],
        ),
      ),
    );
  }
}
