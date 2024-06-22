// packages
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

// utility
import 'package:blurb/utility/database.dart';

// widgets
import 'package:blurb/widgets/meaning_card.dart';
import 'package:blurb/widgets/title_phonetic_section.dart';

// buttons
import 'package:blurb/widgets/buttons/bottom_buttons.dart';
import 'package:blurb/widgets/buttons/parts_of_speech_button.dart';
import 'package:blurb/widgets/buttons/thesaurus_button.dart';

// Map word = {
//   "word": "resistance",
//   "phonetics": [
//     {
//       "text": "/ɹɪˈzɪstəns/",
//       "audio":
//           "https://api.dictionaryapi.dev/media/pronunciations/en/resistance-us.mp3"
//     },
//     {
//       "text": "",
//       "audio":
//           "https://api.dictionaryapi.dev/media/pronunciations/en/resistance-us.mp3"
//     },
//     {
//       "text": "/ɹɪˈzɪstəns/",
//       "audio": "",
//     }
//   ],
//   "meanings": {
//     "noun": [
//       {
//         "definition": "The act of resisting, or the capacity to resist.",
//         "usage": "the resistance of bacteria to certain antibiotics",
//       },
//       {
//         "definition": "A force that tends to oppose motion.",
//         "usage": null,
//       },
//       {
//         "definition": "Electrical resistance.",
//         "usage": null,
//       },
//       {
//         "definition":
//             "An underground organisation engaged in a struggle for liberation from forceful occupation; a resistance movement.",
//         "usage": null,
//       }
//     ],
//     "verb": [
//       {
//         "definition": "The act of resisting, or the capacity to resist.",
//         "usage": "the resistance of bacteria to certain antibiotics",
//       },
//       {
//         "definition": "A force that tends to oppose motion.",
//         "usage": null,
//       },
//       {
//         "definition": "Electrical resistance.",
//         "usage": null,
//       },
//       {
//         "definition":
//             "An underground organisation engaged in a struggle for liberation from forceful occupation; a resistance movement.",
//         "usage": null,
//       }
//     ],
//   },
//   "thesaurus": {
//     "synonyms": ["opposition"],
//     "antonyms": []
//   }
// };

class MeaningScreen extends StatefulWidget {
  final Map wordData;

  const MeaningScreen({
    required this.wordData,
    super.key,
  });

  @override
  State<MeaningScreen> createState() => _MeaningScreenState();
}

class _MeaningScreenState extends State<MeaningScreen> {
  // state variables
  int activePartOfSpeechIndex = 0;
  List meaningCards = [];
  Map<String, int> lastSwipedIndex = {};

  // controllers
  final CardSwiperController swiperController = CardSwiperController();

  late Map _wordData;

  @override
  void initState() {
    super.initState();
    _wordData = widget.wordData;
    List<String> pos = _wordData['meanings'].keys.toList();

    lastSwipedIndex = {for (var element in pos) element: 0};

    changePartOfSpeech(
      activePartOfSpeechIndex,
      pos,
    );
  }

  @override
  void dispose() {
    swiperController.dispose();
    super.dispose();
  }

  List<String> getPhoneticsAndAudio(List phonetics) {
    List<String> result = [];

    String? text, audio;

    for (var phonetic in phonetics) {
      String tempText = phonetic['text'];
      String tempAudio = phonetic['audio'];

      if (tempText.isNotEmpty && tempAudio.isNotEmpty) {
        result.addAll([tempText, tempAudio]);
        return result;
      } else if (tempText.isNotEmpty && text == null) {
        text = tempText;
      } else if (tempAudio.isNotEmpty && audio == null) {
        audio = tempAudio;
      }
    }

    result.addAll([text ?? "", audio ?? ""]);

    return result;
  }

  void changeLastSwipedIndex(List<String> partsOfSpeech, int index) {
    setState(() {
      lastSwipedIndex[partsOfSpeech[activePartOfSpeechIndex]] = index;
    });
  }

  void changePartOfSpeech(int index, List<String> partsOfSpeech) {
    setState(() {
      activePartOfSpeechIndex = index;
      swiperController.moveTo(lastSwipedIndex[partsOfSpeech[index]]!);
    });

    getMeanings(index, partsOfSpeech);
  }

  void getMeanings(int activeIndex, List<String> partsOfSpeech) {
    String partOfSpeech = partsOfSpeech[activeIndex];
    List meanings = _wordData['meanings'][partOfSpeech];

    setState(() {
      meaningCards = List.generate(
          meanings.length,
          (index) => MeaningCard(
                meaning: meanings[index]['definition'],
                usage: meanings[index]['usage'],
              ));
    });
  }

  void saveWord() {
    String word = _wordData['word'];
    List phonetics = getPhoneticsAndAudio(_wordData['phonetics']);
    Map<String, List<Map<String, String>>> partsOfSpeechAndMeanings =
        _wordData['meanings'];
    String synonyms = _wordData['thesaurus']['synonyms'].join(', ');
    String antonyms = _wordData['thesaurus']['antonyms'].join(', ');

    DictionaryDatabase.instance
        .addWord(
      word: word,
      phonetics: phonetics[0],
      audio: phonetics[1],
      partsOfSpeechAndMeanings: partsOfSpeechAndMeanings,
      synonyms: synonyms,
      antonyms: antonyms,
    )
        .catchError((error) {
      throw Exception('Error: $error');
    });
  }

  void unSaveWord() {
    String word = _wordData['word'];

    DictionaryDatabase.instance.deleteWord(word: word).then((value) {
      print('Word unsaved');
    }).catchError((error) {
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    // root word
    String word = _wordData['word'];

    // phonetics
    List phonetics = getPhoneticsAndAudio(_wordData['phonetics']);
    String phoneticText = phonetics[0];
    String pronunciation = phonetics[1];

    // parts of speech
    List<String> partsOfSpeech = _wordData['meanings'].keys.toList();

    // meaning

    // usage

    // thesaurus
    List<String> synonyms = _wordData['thesaurus']['synonyms'];
    List<String> antonyms = _wordData['thesaurus']['antonyms'];

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(30),
        width: double.infinity,
        child: SizedBox(
          child: Column(
            verticalDirection: VerticalDirection.up,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // buttons
              SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Thesaurus buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (synonyms.isNotEmpty
                            ? ThesaurusButton(
                                thesaurusType: 'Synonyms',
                                thesaurus: synonyms,
                              )
                            : const SizedBox.shrink()),
                        (antonyms.isNotEmpty
                            ? ThesaurusButton(
                                thesaurusType: 'Antonyms',
                                thesaurus: antonyms,
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Pronunciation and Bookmark buttons
                    BottomButtons(
                      word: word,
                      pronunciation: pronunciation,
                      onSaveWord: () => saveWord(),
                      onUnSaveWord: () => unSaveWord(),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // word
              SizedBox(
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TitleAndPhoneticsSection(
                      word: word,
                      phonetics: phoneticText,
                    ),

                    // meaning
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),

                          // parts of speech
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                partsOfSpeech.length,
                                (index) => PartOfSpeechButton(
                                  partOfSpeech: partsOfSpeech[index],
                                  onPressed: () => changePartOfSpeech(
                                    index,
                                    partsOfSpeech,
                                  ),
                                  active: index == activePartOfSpeechIndex,
                                ).animate(
                                    effects: index == activePartOfSpeechIndex
                                        ? [
                                            const FlipEffect(
                                              curve: Curves.easeInOut,
                                              duration: Duration(
                                                milliseconds: 500,
                                              ),
                                              alignment: Alignment.centerLeft,
                                            ),
                                            const FadeEffect(
                                              curve: Curves.easeInOut,
                                              duration: Duration(
                                                milliseconds: 400,
                                              ),
                                            ),
                                          ]
                                        : []),
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // definition and usage
                          Flexible(
                              child: CardSwiper(
                            controller: swiperController,
                            numberOfCardsDisplayed: min(meaningCards.length, 3),
                            isLoop: true,
                            onSwipe: (previousIndex, currentIndex, direction) {
                              setState(() {
                                lastSwipedIndex[partsOfSpeech[
                                    activePartOfSpeechIndex]] = currentIndex!;
                              });
                              return true;
                            },
                            padding: const EdgeInsets.all(0),
                            backCardOffset: const Offset(0, 20),
                            cardBuilder: (context,
                                index,
                                horizontalOffsetPercentage,
                                verticalOffsetPercentage) {
                              return meaningCards[index];
                            },
                            cardsCount: meaningCards.length,
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
