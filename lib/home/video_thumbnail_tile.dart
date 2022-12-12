import 'package:flutter/material.dart';
import 'package:surphop/home/cachedvideo_page.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:surphop/home/cachedvideo_tile.dart';

class VideoThumbnailTile extends StatefulWidget {
  final String videoUrl;
  const VideoThumbnailTile({super.key, required this.videoUrl});

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
            child: FutureBuilder(
                future: DefaultCacheManager().getSingleFile(widget.videoUrl),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return CachedVideoTile(videoFile: snapshot.data!);
                  } else {
                    return const CircularProgressIndicator();
                  }
                }))));
  }
}
