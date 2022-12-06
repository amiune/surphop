import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/video_page.dart';

class VideoThumbnailTile extends StatefulWidget {
  final String videoThumbnailURL;
  final String videolURL;
  const VideoThumbnailTile(
      {super.key, required this.videoThumbnailURL, required this.videolURL});

  @override
  State<VideoThumbnailTile> createState() => _VideoThumbnailTileState();
}

class _VideoThumbnailTileState extends State<VideoThumbnailTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VideoPage(videoURL: widget.videolURL);
          }));
        },
        child: Container(
            padding: const EdgeInsets.all(0),
            child: CachedNetworkImage(
              placeholder: (context, url) => const CircularProgressIndicator(),
              imageUrl: "https://via.placeholder.com/100x150",
            )));
  }
}
