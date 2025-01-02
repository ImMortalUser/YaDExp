import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const MusicPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _MusicPlayerWidgetState createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true; // Для отображения индикатора загрузки
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Подписка на изменения позиции
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Подписка на изменение общей длительности
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // Подписка на событие изменения состояния плеера
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else if (state == PlayerState.paused || state == PlayerState.stopped) {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    // Начинаем загружать и готовить аудио для воспроизведения
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    // Запускаем загрузку аудио с URL
    await _audioPlayer.setSource(UrlSource(widget.audioUrl));

    // Делаем кнопку Play доступной, когда аудио готово к воспроизведению
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  // Форматирование времени в MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Если аудио загружено и готово, показываем кнопку Play/Pause
        _isLoading
            ? const CircularProgressIndicator() // Индикатор загрузки
            : IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 36,
          ),
          onPressed: _togglePlayback,
        ),

        const SizedBox(height: 16),

        // Прогресс-бар (с плавной анимацией)
        Slider(
          value: _currentPosition.inMilliseconds.toDouble(),
          max: _totalDuration.inMilliseconds.toDouble(),
          onChanged: (value) async {
            await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
          },
        ),

        const SizedBox(height: 8),

        // Отображение времени
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              _formatDuration(_totalDuration),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
