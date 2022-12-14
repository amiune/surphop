import 'package:flutter/material.dart';
import 'package:surphop/videocomments/cachedvideocomment_page.dart';
import 'package:surphop/videocomments/cachedvideocomment_tile.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCommentThumbnailTile extends StatefulWidget {
  final String videoId;
  final String userId;
  final String videoUrl;
  const VideoCommentThumbnailTile({
    super.key,
    required this.videoId,
    required this.userId,
    required this.videoUrl,
  });

  @override
  State<VideoCommentThumbnailTile> createState() =>
      _VideoCommentThumbnailTileState();
}

class _VideoCommentThumbnailTileState extends State<VideoCommentThumbnailTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          DefaultCacheManager()
              .getSingleFile(widget.videoUrl)
              .then((videoFile) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CachedVideoCommentPage(
                videoId: widget.videoId,
                userId: widget.userId,
                videoFile: videoFile,
              );
            }));
          });
        },
        child: Container(
            padding: const EdgeInsets.all(0),
            child: FutureBuilder(
                future: DefaultCacheManager().getSingleFile(widget.videoUrl),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return CachedVideoCommentTile(videoFile: snapshot.data!);
                  } else {
                    return const CircularProgressIndicator();
                  }
                }))));
  }
}
