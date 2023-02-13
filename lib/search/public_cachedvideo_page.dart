import 'package:flutter/material.dart';
import 'package:surphop/videocomments/video_comments_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/file.dart';

class PublicCachedVideoPage extends StatefulWidget {
  final String videoId;
  final File videoFile;
  final String videoCreatorId;
  const PublicCachedVideoPage(
      {super.key,
      required this.videoId,
      required this.videoFile,
      required this.videoCreatorId});

  @override
  State<PublicCachedVideoPage> createState() => _PublicCachedVideoPageState();
}

class _PublicCachedVideoPageState extends State<PublicCachedVideoPage> {
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return VideoCommentsPage(
                videoId: widget.videoId,
                videoCreatorId: widget.videoCreatorId,
              );
            }));
          },
          label: const Text("Comments"),
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
