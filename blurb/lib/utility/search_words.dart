import 'package:blurb/utility/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Dictionary {
  late Dio dio;

  Dictionary() {
    dio = Dio(
      BaseOptions(
          baseUrl: 'https://api.dictionaryapi.dev/api/v2',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 7)),
    );
  }

  List<Map<String, String>> getPhoneticsAndAudio(List phonetics) {
    List<Map<String, String>> result = [];

    for (var element in phonetics) {
      String text = element['text'] == null ? "" : element['text'].toString();
      String audio =
          element['audio'] == null ? "" : element['audio'].toString();

      if (text.isNotEmpty || audio.isNotEmpty) {
        result.add({'text': text, 'audio': audio});
      }
    }

    return result;
  }

  Map<String, List<Map<String, String>>> getMeanings(List meanings) {
    Map<String, List<Map<String, String>>> result = {};

    for (var meaning in meanings) {
      String partOfSpeech = meaning['partOfSpeech']!;

      List<Map<String, String>> definitions = [];

      meaning['definitions'].forEach((element) => definitions.add({
            "definition": element['definition'],
            "usage": element['example'] ?? "",
          }));

      result[partOfSpeech] = definitions;
    }

    return result;
  }

  Map<String, List<String>?> getThesaurus(List data) {
    Map<String, List<String>?> result = {};

    List<String>? synonyms = [];
    List<String>? antonyms = [];

    for (var element in data) {
      List temp1 = element['synonyms'] ?? [];
      List temp2 = element['antonyms'] ?? [];

      if (temp1.isNotEmpty) synonyms.addAll(List<String>.from(temp1));
      if (temp2.isNotEmpty) antonyms.addAll(List<String>.from(temp2));
    }

    result['synonyms'] = synonyms;
    result['antonyms'] = antonyms;

    return result;
  }

  Future<Map> searchWord(String word) async {
    try {
      Map result = {};
      result = await DictionaryDatabase.instance.findWord(wordName: word);
      
      // find word in local database
      if (result.isNotEmpty) {
        return result;
      }

      // find word through api
      Response res = await dio.get('/entries/en/$word');
      List data = res.data;
      List phonetics = data[0]['phonetics'];
      List meanings = data[0]['meanings'];

      result['word'] = word;
      result['phonetics'] = getPhoneticsAndAudio(phonetics);
      result['meanings'] = getMeanings(meanings);
      result['thesaurus'] = getThesaurus(meanings);

      return result;
    } on DioException catch (e) {
      debugPrint('Failed to load: $e');
      return {};
    }
  }
}
