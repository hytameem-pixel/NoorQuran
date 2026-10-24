import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Plays audio explicitly selected by the user from their own device.
/// This app does not redistribute, stream, or claim rights to recitation files.
class LocalRecitationPlayer extends StatefulWidget {
  final int repeats;
  const LocalRecitationPlayer({super.key, required this.repeats});
  @override
  State<LocalRecitationPlayer> createState() => _LocalRecitationPlayerState();
}

class _LocalRecitationPlayerState extends State<LocalRecitationPlayer> {
  final player = AudioPlayer();
  String? fileName;
  String? error;
  bool busy = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _chooseAudio() async {
    setState(() { busy = true; error = null; });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.path == null) {
        throw const FormatException('Unable to access selected audio file');
      }
      await player.stop();
      // A finite playlist repeats the chosen recording exactly N times.
      await player.setLoopMode(LoopMode.off);
      await player.setAudioSources(
        List.generate(widget.repeats, (_) => AudioSource.file(file.path!)),
      );
      if (!mounted) return;
      setState(() => fileName = file.name);
      await player.play();
    } catch (_) {
      if (mounted) {
        setState(() => error = 'تعذر تشغيل الملف الصوتي. اختر ملف MP3 أو M4A صالحًا.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        const Text('التلاوة الصوتية من ملفات جهازك',
          style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('اختر تسجيلًا تملك حق استخدامه. يُعاد الملف ${widget.repeats} مرات؛ ولا يُزامن تلقائيًا مع الآية الحالية.',
          textAlign: TextAlign.center),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: busy ? null : _chooseAudio,
          icon: const Icon(Icons.audio_file_outlined),
          label: Text(busy ? 'جارٍ فتح الملف' : 'اختيار تسجيل من الهاتف'),
        ),
        if (fileName != null) Text(fileName!, textAlign: TextAlign.center),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                tooltip: playing ? 'إيقاف مؤقت' : 'استئناف',
                onPressed: fileName == null ? null : () async {
                  if (playing) {
                    await player.pause();
                  } else {
                    if (player.processingState == ProcessingState.completed) {
                      await player.seek(Duration.zero, index: 0);
                    }
                    await player.play();
                  }
                },
                icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
              ),
              IconButton(
                tooltip: 'إيقاف',
                onPressed: fileName == null ? null : () => player.stop(),
                icon: const Icon(Icons.stop_circle_outlined),
              ),
            ]);
          },
        ),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
    ),
  );
}
