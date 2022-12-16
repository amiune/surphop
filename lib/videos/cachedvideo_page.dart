import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/file.dart';

class CachedVideoPage extends StatefulWidget {
  final String videoId;
  final String videoUserId;
  final File videoFile;
  final Function(String) onDeletePressed;
  const CachedVideoPage(
      {super.key,
      required this.videoId,
      required this.videoUserId,
      required this.videoFile,
      required this.onDeletePressed});

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
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    widget.onDeletePressed(widget.videoId);
                  },
                ),
              ],
            ),
          ),
        ),
        /*
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return VideoCommentsPage(
                videoId: widget.videoId,
                videoUserId: widget.videoUserId,
              );
            }));
          },
          label: const Text("Comments"),
          icon: const Icon(Icons.comment),
        ),
        */
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
