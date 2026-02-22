import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A widget that plays a looping video background from assets.
class VideoBackground extends StatefulWidget {
  final String assetPath;
  final double opacity;

  const VideoBackground({
    super.key,
    required this.assetPath,
    this.opacity = 1.0,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = VideoPlayerController.asset(widget.assetPath);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0); // Always mute backgrounds
      await _controller.play();

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video background: $e');
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      // Fallback to a dark container if video fails
      return Container(color: Colors.black);
    }

    if (!_initialized) {
      // Show black while loading to avoid white flashes
      return Container(color: Colors.black);
    }

    return Opacity(
      opacity: widget.opacity,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}
