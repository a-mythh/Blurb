import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const Duration apiCallDuration = Duration(milliseconds: 100);

class AutocompleteAPI {
  static final dio = Dio();

  // Searches the options
  static Future<List<String>> search(String query) async {
    try {
      await Future<void>.delayed(apiCallDuration);

      if (query.trim().isEmpty) {
        return [];
      }

      Response res =
          await dio.get("https://blurb-njix.onrender.com/search?word=$query");
      List data = res.data;

      List<String> results = data.map((map) => map['word'] as String).toList();

      return results;
    } on DioException catch (e) {
      debugPrint('Autocomplete error: $e');
      return [];
    }
  }
}
