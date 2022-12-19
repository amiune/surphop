import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:video_player/video_player.dart';

class CachedVideoCommentTile extends StatefulWidget {
  final File videoFile;
  const CachedVideoCommentTile({super.key, required this.videoFile});

  @override
  State<CachedVideoCommentTile> createState() => _CachedVideoCommentTileState();
}

class _CachedVideoCommentTileState extends State<CachedVideoCommentTile> {
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
    if (_controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    } else {
      return Container();
    }
  }
}