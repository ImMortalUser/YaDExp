import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://downloader.disk.yandex.ru/disk/5add93993c5b4fb0fb8b98938cd0cbe54c587ee07431016763582318ee576f68/67763740/pizXLnxKAle6R4z95AsWt2Sk8zkg2C2ZPh2a9dq49G3ggyOG6qkXbwdOEhVfHn9AQH0QHKQLiIoIkwVy192jeQ%3D%3D?uid=156916995&filename=Escape%20From%20Tarkov%202024.05.08%20-%2021.12.31.03.DVR_cut.mp4&disposition=attachment&hash=&limit=0&content_type=video%2Fmp4&owner_uid=156916995&fsize=77032905&hid=fff45dddd9a597a3eff23faacbdc7cde&media_type=video&tknv=v2&etag=b48ac3aa61362f343b05eac1dfec9c30',
    )..initialize().then((_) {

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
      appBar: AppBar(title: Text('Video Player')),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            VideoProgressIndicator(_controller, allowScrubbing: true),
            IconButton(
              icon: Icon(
                _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
            ),
          ],
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}
