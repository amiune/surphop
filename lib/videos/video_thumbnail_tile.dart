// ignore_for_file: unnecessary_const

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnailTile extends StatefulWidget {
  final String videoId;
  final String videoUrl;
  final File videoFile;
  final Function(String) onDeletePressed;
  final DateTime videoUploadedDate;
  const VideoThumbnailTile(
      {super.key,
      required this.videoId,
      required this.videoUrl,
      required this.videoFile,
      required this.onDeletePressed,
      required this.videoUploadedDate});

  @override
  State<VideoThumbnailTile> createState() => _VideoThumbnailTileState();
}

class _VideoThumbnailTileState extends State<VideoThumbnailTile> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.videoFile);
    if (Platform.isIOS) {
      _controller.setVolume(0);
      _controller.setLooping(false);
      _controller.play();
    }
    _controller.initialize().then((_) {
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
    String daysAgo = "";
    DateTime today = DateTime.now();
    int days = today.difference(widget.videoUploadedDate).inDays;
    if (days <= 30) {
      daysAgo = "$days days ago";
    } else if (days <= 30 * 12) {
      daysAgo = "${(days / 30)} months ago";
    } else {
      daysAgo = "${(days / (30 * 12))} years ago";
    }

    if (_controller.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
              child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )), //map
          Positioned(
              bottom: 3,
              right: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(3)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    daysAgo,
                    style: TextStyle(color: Colors.grey[200], fontSize: 10),
                  ),
                ),
              )),
        ],
      );

      /*
      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
      */
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
