import 'package:blurb/utility/search_words.dart';
import 'dart:io';

void main() async {
  Dictionary dictionary = Dictionary();
  String word = stdin.readLineSync()!;

  try {
    DateTime start = DateTime.now();
    Map result = await dictionary.searchWord(word);
    DateTime end = DateTime.now();

    print(end.difference(start).inMilliseconds);
    print(result['thesaurus']['synonyms']);
    
    exit(0);
  } catch (e) {
    print('Error: $e');
  }
}
