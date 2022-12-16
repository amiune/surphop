import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/file.dart';

class CachedVideoCommentPage extends StatefulWidget {
  final String videoId;
  final String userId;
  final File videoFile;
  const CachedVideoCommentPage(
      {super.key,
      required this.videoId,
      required this.userId,
      required this.videoFile});

  @override
  State<CachedVideoCommentPage> createState() => _CachedVideoCommentPageState();
}

class _CachedVideoCommentPageState extends State<CachedVideoCommentPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile);
    _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : Container(),
        ));
  }
}
