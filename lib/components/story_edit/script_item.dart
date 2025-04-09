import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import '../../models/script.dart';
import '../../models/character.dart';
import '../../utils/ui/app_colors.dart';

class ScriptItem extends StatelessWidget {
  final Script script;
  final Character? character; // null for narrator
  final Function(Script) onGenerateVoice;

  const ScriptItem({
    super.key,
    required this.script,
    required this.character,
    required this.onGenerateVoice,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasVoice =
        script.voiceoverPath != null && script.voiceoverPath!.isNotEmpty;
    final bool isNarrator = character == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isNarrator
                ? AppColors.sidebarBg.withValues(alpha: .05)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isNarrator
                  ? AppColors.primary.withValues(alpha: .2)
                  : AppColors.border,
        ),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Script header (character name or "Narrator")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Character avatar or narrator icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          isNarrator
                              ? AppColors.primary.withValues(alpha: .2)
                              : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        isNarrator ? Icons.book : Icons.person,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Character name or "Narrator"
                  Text(
                    isNarrator ? 'Narrator' : character!.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          isNarrator ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              // Language indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      script.language.substring(0, 1).toUpperCase() +
                          script.language.substring(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                    if (script.urduFlavor)
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          '(Urdu Flavor)',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Script text
          Text(
            script.scriptText,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),

          const SizedBox(height: 16),

          // Audio section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Audio player if voice exists
              if (hasVoice)
                Expanded(
                  child: _AudioPlayer(voiceoverPath: script.voiceoverPath!),
                )
              else
                const Text(
                  'No audio available',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMedium,
                    fontSize: 13,
                  ),
                ),

              // Generate/regenerate button
              _VoiceGenerationButton(
                hasVoice: hasVoice,
                onPressed: () => onGenerateVoice(script),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioPlayer extends StatefulWidget {
  final String voiceoverPath;

  const _AudioPlayer({required this.voiceoverPath});

  @override
  State<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _progress = 0.0;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setFilePath(widget.voiceoverPath);
      _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() => _duration = duration);
        }
      });
      _audioPlayer.positionStream.listen((position) {
        if (_duration != null && _duration!.inMilliseconds > 0) {
          setState(() {
            _progress = position.inMilliseconds / _duration!.inMilliseconds;
          });
        }
      });
      _audioPlayer.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to play audio')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          ),
          color: AppColors.primary,
          onPressed: _togglePlayback,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio progress bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  widthFactor: _progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Audio file info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    File(widget.voiceoverPath).uri.pathSegments.last,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_formatDuration(_audioPlayer.position)} / ${_formatDuration(_duration)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoiceGenerationButton extends StatelessWidget {
  final bool hasVoice;
  final VoidCallback onPressed;

  const _VoiceGenerationButton({
    required this.hasVoice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: hasVoice ? AppColors.accent3 : AppColors.accent1,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(hasVoice ? Icons.refresh : Icons.record_voice_over, size: 16),
      label: Text(
        hasVoice ? 'Regenerate' : 'Generate Voice',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
