import 'dart:collection';
import 'package:blurb/utility/database.dart';
import 'package:blurb/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BottomButtons extends StatefulWidget {
  final String word;
  final String pronunciation;
  final Function onSaveWord;
  final Function onUnSaveWord;

  const BottomButtons({
    required this.word,
    required this.pronunciation,
    required this.onSaveWord,
    required this.onUnSaveWord,
    super.key,
  });

  @override
  State<BottomButtons> createState() => _BottomButtonsState();
}

class _BottomButtonsState extends State<BottomButtons> {
  bool audioPlayed = false;
  bool isSaved = false;
  HashMap savedWords = HashMap();

  void playPronunciation(String url) async {
    final AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.setPlaybackRate(0.7);

    setState(() {
      audioPlayed = true;
    });

    try {
      DateTime start = DateTime.now();
      final playFuture = audioPlayer.play(UrlSource(url));
      DateTime end = DateTime.now();
      final holdDuration =
          Duration(milliseconds: end.difference(start).inMilliseconds + 1000);
      await Future.delayed(holdDuration);

      // timeout for low bandwidth
      await playFuture.timeout(
        Duration(
          seconds: 7,
          milliseconds: holdDuration.inMilliseconds,
        ),
        onTimeout: () {
          if (context.mounted) {
            showFlushBar(
              context: context,
              message: 'Uh oh! Unable to play the pronunciation.',
              type: MessageType.failure,
            );
          }
        },
      );
    } on Exception catch (error) {
      debugPrint('Error playing audio: $error');
      if (context.mounted) {
        showFlushBar(
          context: context,
          message: 'Uh oh! We were not able to play the pronunciation.',
          type: MessageType.failure,
        );
      }
    } finally {
      setState(() {
        audioPlayed = false;
      });
    }
  }

  @override
  void initState() {
    DictionaryDatabase.instance.getAllWords().then(
      (value) {
        setState(() {
          isSaved = HashMap.fromIterable(
            value,
            key: (element) => element['word'],
            value: (element) => element['created_at'],
          ).containsKey(widget.word);
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        (widget.pronunciation.isNotEmpty
            ? IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  playPronunciation(widget.pronunciation);
                },
                icon: !audioPlayed
                    ? const Icon(
                        Icons.volume_up_outlined,
                        size: 40,
                      )
                    : SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
              )
            : const SizedBox.shrink()),
        const SizedBox(width: 15),

        // bookmark
        IconButton(
          onPressed: isSaved
              ? () {
                  widget.onUnSaveWord();
                  setState(() {
                    isSaved = false;
                  });
                  HapticFeedback.mediumImpact();
                }
              : () {
                  widget.onSaveWord();
                  setState(() {
                    isSaved = true;
                  });
                  HapticFeedback.mediumImpact();
                },
          icon: isSaved
              ? const Icon(
                  Icons.bookmark_rounded,
                  size: 40,
                )
              : const Icon(
                  Icons.bookmark_outline_outlined,
                  size: 40,
                ),
        ),
      ],
    ).animate(effects: [
      const ScaleEffect(
        begin: Offset(-1, 0),
        duration: Duration(milliseconds: 600),
        curve: Curves.fastEaseInToSlowEaseOut,
        delay: Duration(milliseconds: 100),
      ),
      const FadeEffect(
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      )
    ]);
  }
}
