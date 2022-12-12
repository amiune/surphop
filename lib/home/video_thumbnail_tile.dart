import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:surphop/home/cachedvideo_page.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoThumbnailTile extends StatefulWidget {
  final String videoThumbnailUrl;
  final String videoUrl;
  const VideoThumbnailTile(
      {super.key, required this.videoThumbnailUrl, required this.videoUrl});

  @override
  State<VideoThumbnailTile> createState() => _VideoThumbnailTileState();
}

class _VideoThumbnailTileState extends State<VideoThumbnailTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          DefaultCacheManager()
              .getSingleFile(widget.videoUrl)
              .then((videoFile) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CachedVideoPage(videoFile: videoFile);
            }));
          });
        },
        child: Container(
            padding: const EdgeInsets.all(0),
            child: CachedNetworkImage(
              placeholder: (context, url) => const CircularProgressIndicator(),
              imageUrl: widget.videoThumbnailUrl,
            )));
  }
}
