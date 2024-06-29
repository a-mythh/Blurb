import 'dart:async';
import 'package:blurb/screens/meaning.dart';
import 'package:blurb/utility/database.dart';
import 'package:blurb/utility/progress_bar.dart';
import 'package:blurb/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

// excel
import 'package:blurb/utility/csv.dart';

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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // state variables
  bool isLoadingWords = false;
  bool isLoadingMeaning = false;
  bool isDownloadingFile = false;
  WordSortType selectedSort = WordSortType.mostRecent;
  bool downloadFileFormatted = false;
  bool isDeleted = false;

  // all the words in the database
  List<Map> words = [];

  void getWords({
    WordSortType sortType = WordSortType.mostRecent,
    bool showDelay = false,
  }) async {
    setState(() {
      isLoadingWords = true;
    });

    // fetch words from the database
    await DictionaryDatabase.instance
        .getAllWords(sortType: sortType)
        .then((result) {
      setState(() {
        words = result;
      });
    });

    // show loading
    if (showDelay) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    setState(() {
      isLoadingWords = false;
    });
  }

  void unSaveWord(Map word, int index) async {
    DictionaryDatabase.instance.deleteWord(word: word['word']).onError(
      (error, stackTrace) {
        debugPrint("Error while removing word: $error");
        showFlushBar(
          context: context,
          message: 'There was an error while removing the word.',
          type: MessageType.failure,
        );
        return false;
      },
    );

    setState(() {
      words = words.toList()..removeAt(index);
    });

    _listKey.currentState!.removeItem(
      index,
      (context, animation) => buildItem(word, index, animation),
    );

    showFlushBar(
      context: context,
      message: 'Removed from saved words.',
      type: MessageType.normal,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void goToMeaning(Map word, int index) async {
    Map wordData =
        await DictionaryDatabase.instance.findWord(wordName: word['word']);

    if (mounted) {
      await Navigator.of(context)
          .push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              MeaningScreen(wordData: wordData),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const beginOffset = Offset(1, 0);
            const endOffset = Offset(0, 0);

            final slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: endOffset,
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        ),
      )
          .then(
        (value) {
          if (value == true) {
            setState(() {
              words = words.toList()..removeAt(index);
              _listKey.currentState!.removeItem(
                index,
                (context, animation) => buildItem(word, index, animation),
              );
            });
          }
        },
      );
    }
  }

  void showSortSelectionDialogBox(BuildContext context) {
    Map<WordSortType, String> sortType = {
      WordSortType.mostRecent: "Most recent first",
      WordSortType.leastRecent: "Least recent first",
      WordSortType.alphabeticalAZ: "A to Z",
      WordSortType.alphabeticalZA: "Z to A",
      WordSortType.longestFirst: "Longest first",
      WordSortType.shortestFirst: "Shortest first",
    };

    showGeneralDialog(
        context: context,
        barrierLabel: '',
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SizedBox.shrink();
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            alignment: const Alignment(0.85, 0.9),
            child: FadeTransition(
              opacity: animation,
              child: StatefulBuilder(
                builder: (context, setState) => SimpleDialog(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    'Sort by',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  children: sortType.keys
                      .map((type) => RadioListTile(
                            activeColor: Theme.of(context).colorScheme.primary,
                            selectedTileColor:
                                Theme.of(context).colorScheme.onPrimary,
                            title: Text(
                              sortType[type]!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontSize: 18,
                                    color: type == selectedSort
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                  ),
                            ),
                            value: type,
                            selected: type == selectedSort,
                            groupValue: selectedSort,
                            onChanged: (value) {
                              setState(() {
                                selectedSort = value!;
                              });
                              getWords(
                                sortType: selectedSort,
                                showDelay: true,
                              );
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        });
  }

  Future<bool> showDownloadDialogBox(BuildContext context) async {
    var completer = Completer<bool>();

    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          alignment: const Alignment(0.9, -0.9),
          child: FadeTransition(
            opacity: animation,
            child: StatefulBuilder(
              builder: (context, setState) => SimpleDialog(
                backgroundColor: Theme.of(context).colorScheme.primary,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  'Download Excel Format',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                children: [
                  RadioListTile(
                    activeColor: Theme.of(context).colorScheme.primary,
                    selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                    title: Text(
                      'Bland',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            color: downloadFileFormatted == false
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    value: false,
                    selected: downloadFileFormatted == false,
                    groupValue: downloadFileFormatted,
                    onChanged: (value) {
                      setState(() {
                        downloadFileFormatted = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: Theme.of(context).colorScheme.primary,
                    selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                    title: Text(
                      'Unicorn Vomit',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            color: downloadFileFormatted == true
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    value: true,
                    selected: downloadFileFormatted == true,
                    groupValue: downloadFileFormatted,
                    onChanged: (value) {
                      setState(() {
                        downloadFileFormatted = value!;
                      });
                    },
                  ),

                  // Note
                  const SizedBox(height: 20),
                  Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                        children: const [
                          TextSpan(
                              text: 'File will be saved in a folder named '),
                          TextSpan(
                            text: 'blurb',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' in Internal Storage.'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          completer.complete(false);
                        },
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).pop();
                          completer.complete(true);
                        },
                        child: Text(
                          'Download',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    return completer.future;
  }

  void downloadFile({
    required List wordsList,
    bool isFormatted = true,
  }) async {
    bool download = await showDownloadDialogBox(context);

    if (!download) return;

    setState(() {
      isDownloadingFile = true;
    });

    List<Map<String, dynamic>> words = [];
    for (int i = 0; i < wordsList.length; i++) {
      Map<String, dynamic> result = await DictionaryDatabase.instance.findWord(
        wordName: wordsList[i]['word'],
      );
      words.add(result);
    }

    await exportToExcel(
      words: words,
      isFormatted: downloadFileFormatted,
    );

    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      isDownloadingFile = false;
    });

    if (mounted) {
      showFlushBar(
        context: context,
        message: 'File has been downloaded.',
        type: MessageType.success,
      );
    }
  }

  // bookmarks
  Widget buildItem(Map word, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
          onTap: () {
            HapticFeedback.selectionClick();
            goToMeaning(word, index);
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 6,
          ),
          title: Hero(
            tag: word['word'],
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                word['word'],
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          subtitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Text(formatDate(word['created_at'])),
              ),
            ],
          ),
          subtitleTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
          tileColor: Theme.of(context).colorScheme.primary,
          trailing: IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              unSaveWord(word, index);
            },
            icon: const Icon(
              Icons.highlight_remove_rounded,
              size: 30,
            ),
          ),
          titleAlignment: ListTileTitleAlignment.center,
        ),
      ).animate(effects: [
        const SlideEffect(
          duration: Duration(milliseconds: 700),
          delay: Duration(milliseconds: 100),
          begin: Offset(1, 0),
          curve: Curves.fastEaseInToSlowEaseOut,
        ),
        const FadeEffect(
          duration: Duration(microseconds: 500),
          curve: Curves.easeInOut,
        ),
      ]),
    );
  }

  @override
  void initState() {
    getWords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // bookmark card widget
    Widget bookmarks = AnimatedList(
      key: _listKey,
      initialItemCount: words.length,
      itemBuilder: (context, index, animation) {
        return buildItem(words[index], index, animation);
      },
    );

    // screen widget
    return Scaffold(
      // app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 22,
          ),
        ),

        // save to excel button
        actions: [
          words.isNotEmpty
              ? !isDownloadingFile
                  ? IconButton(
                      padding: const EdgeInsets.only(right: 16),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        downloadFile(
                          wordsList: words,
                          isFormatted: true,
                        );
                      },
                      icon: const Icon(
                        Icons.download_rounded,
                        size: 32,
                        semanticLabel: 'Save words to file.',
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(right: 20),
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeCap: StrokeCap.round,
                        strokeWidth: 4,
                      ),
                    )
              : const SizedBox.shrink(),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Saved Words',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            words.isNotEmpty
                ? const SizedBox(width: 6)
                : const SizedBox.shrink(),
            words.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    child: Text(
                      '${words.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        centerTitle: true,
      ),

      // sorting options
      floatingActionButton: words.length > 1
          ? Align(
              alignment: const Alignment(0.9, 0.9),
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(6),
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                ),
                onPressed: () => showSortSelectionDialogBox(context),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  size: 32,
                ),
              ),
            )
          : const SizedBox.shrink(),

      // body
      body: words.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🍃',
                    style: TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Oopsie daisy!',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your word garden is empty.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : isLoadingWords || isLoadingMeaning
              ? const Center(child: ProgressBar())
              : SizedBox(child: bookmarks),
    );
  }
}
