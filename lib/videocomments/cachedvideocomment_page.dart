import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/file.dart';

class CachedVideoCommentPage extends StatefulWidget {
  final String videoCommentId;
  final File videoFile;
  final int videoState;
  const CachedVideoCommentPage(
      {super.key,
      required this.videoCommentId,
      required this.videoState,
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
      _controller.play();
      _controller.setLooping(true);
      setState(() {});
    });

    //Change the state to viewed
    if (widget.videoState == 0) {
      FirebaseFirestore.instance
          .collection("videocomments")
          .doc(widget.videoCommentId)
          .update({
        'approved': 1,
      });
    }
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
                const Spacer(),
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
