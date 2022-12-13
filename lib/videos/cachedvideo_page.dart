import 'package:flutter/material.dart';
import 'package:surphop/home/bottom_appbar.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/file.dart';

class CachedVideoPage extends StatefulWidget {
  final File videoFile;
  const CachedVideoPage({super.key, required this.videoFile});

  @override
  State<CachedVideoPage> createState() => _CachedVideoPageState();
}

class _CachedVideoPageState extends State<CachedVideoPage> {
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
        bottomNavigationBar: const MyBottomAppBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text("Tips"),
          icon: const Icon(Icons.comment),
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
