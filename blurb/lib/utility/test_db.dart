import 'package:blurb/utility/database.dart';

Map word = {
  "word": "resistance",
  "phonetics": {
    "text": "/ɹɪˈzɪstəns/",
    "audio":
        "https://api.dictionaryapi.dev/media/pronunciations/en/resistance-us.mp3"
  },
  "meanings": {
    "noun": [
      {
        "definition": "The act of resisting, or the capacity to resist.",
        "usage": "the resistance of bacteria to certain antibiotics",
      },
      {
        "definition": "A force that tends to oppose motion.",
        "usage": "",
      },
      {
        "definition": "Electrical resistance.",
        "usage": "",
      },
      {
        "definition":
            "An underground organisation engaged in a struggle for liberation from forceful occupation; a resistance movement.",
        "usage": "",
      }
    ],
    "verb": [
      {
        "definition": "The act of resisting, or the capacity to resist.",
        "usage": "the resistance of bacteria to certain antibiotics",
      },
      {
        "definition": "A force that tends to oppose motion.",
        "usage": "",
      },
      {
        "definition": "Electrical resistance.",
        "usage": "",
      },
      {
        "definition":
            "An underground organisation engaged in a struggle for liberation from forceful occupation; a resistance movement.",
        "usage": "",
      }
    ],
  },
  "thesaurus": {
    "synonyms": ["opposition"],
    "antonyms": []
  }
};

void main() async {
  // Initialize the database
  // final db = DictionaryDatabase.instance;

  // add word
  // await db.addWord(
  //     word: word['word'],
  //     phonetics: word['phonetics']['text'],
  //     audio: word['phonetics']['audio'],
  //     partsOfSpeechAndMeanings: word['meanings'],
  //     synonyms: word['thesaurus']['synonyms'],
  //     antonyms: word['thesaurus']['antonyms']);

  List<Map<String, dynamic>> wordsList = await DictionaryDatabase.instance
      .getAllWords(sortType: WordSortType.alphabeticalAZ);
  print(wordsList);

  // DictionaryDatabase.instance
  //     .findWord(wordName: 'like')
  //     .then((value) => print(value));
}
