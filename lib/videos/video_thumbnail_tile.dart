import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnailTile extends StatefulWidget {
  final String videoId;
  final String videoUserId;
  final String videoUrl;
  final File videoFile;
  final Function(String) onDeletePressed;
  const VideoThumbnailTile({
    super.key,
    required this.videoId,
    required this.videoUserId,
    required this.videoUrl,
    required this.videoFile,
    required this.onDeletePressed,
  });

  @override
  State<VideoThumbnailTile> createState() => _VideoThumbnailTileState();
}

class _VideoThumbnailTileState extends State<VideoThumbnailTile> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    //_controller = VideoPlayerController.file(widget.videoFile);
    _controller = VideoPlayerController.network(widget.videoUrl);
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
      return const Center(child: Text("tile..."));
    }
  }
}
