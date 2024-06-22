import 'dart:collection';
import 'package:blurb/utility/database.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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

    DateTime start = DateTime.now();
    await audioPlayer.play(UrlSource(url));
    DateTime end = DateTime.now();
    await Future.delayed(
      Duration(milliseconds: end.difference(start).inMilliseconds + 400),
    );

    setState(() {
      audioPlayed = false;
    });
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
                onPressed: () => playPronunciation(widget.pronunciation),
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
                }
              : () {
                  widget.onSaveWord();
                  setState(() {
                    isSaved = true;
                  });
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
    );
  }
}
