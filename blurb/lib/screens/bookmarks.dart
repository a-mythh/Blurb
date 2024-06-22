import 'package:blurb/screens/meaning.dart';
import 'package:blurb/utility/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

String formatDate(String date) {
  DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
  String formattedDate = DateFormat('dd MMM, yyyy').format(
    parsedDate.add(
      const Duration(
        hours: 5,
        minutes: 30,
      ),
    ),
  );

  return formattedDate;
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List words = [];

  void getWords() {
    DictionaryDatabase.instance.getAllWords().then((result) {
      setState(() {
        words = result;
      });
    });
  }

  void unSaveWord(String word) {
    DictionaryDatabase.instance.deleteWord(word: word).then((value) {
      print('Word unsaved');
    }).catchError((error) {
      print('Error: $error');
    });
  }

  void goToMeaning(String word) async {
    Map wordData = await DictionaryDatabase.instance.findWord(wordName: word);

    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MeaningScreen(wordData: wordData),
      ));
    }
  }

  @override
  void initState() {
    getWords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 22,
          ),
        ),
        title: Text(
          'Saved Words',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
          child: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  spreadRadius: 2,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: ListTile(
              onTap: () => goToMeaning(words[index]['word']),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              title: Text(words[index]['word']),
              titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(formatDate(words[index]['created_at'])),
                  ),
                ],
              ),
              subtitleTextStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8),
              tileColor: Theme.of(context).colorScheme.primary,
              trailing: IconButton(
                onPressed: () {
                  unSaveWord(words[index]['word']);
                  getWords();
                },
                icon: const Icon(
                  Icons.highlight_remove_rounded,
                  size: 30,
                ),
              ),
              titleAlignment: ListTileTitleAlignment.center,
            ),
          );
        },
      )),
    );
  }
}
