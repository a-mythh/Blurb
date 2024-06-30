import 'package:blurb/screens/bookmarks.dart';
import 'package:blurb/utility/internet_connection.dart';
import 'package:blurb/utility/progress_bar.dart';
import 'package:blurb/widgets/snackbar.dart';
import 'package:flutter/material.dart';

// screens
import 'package:blurb/screens/meaning.dart';

// widgets
import 'package:blurb/widgets/custom_search_bar.dart';

// utility
import 'package:blurb/utility/search_words.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // controllers
  final searchController = TextEditingController();
  Dictionary dictionary = Dictionary();

  // state variables
  bool isSearching = false;

  double borderWidth = 6.0;

  void searchWord() async {
    String word = searchController.text.trim().toLowerCase();

    setState(() {
      isSearching = true;
    });

    // check for empty text
    if (word.isEmpty) {
      showFlushBar(
        context: context,
        message: 'Invalid search query.',
        type: MessageType.failure,
      );
      debugPrint("Invalid Word.");
      searchController.clear();

      setState(() {
        isSearching = false;
      });
      return;
    }

    Map result = await dictionary.searchWord(word);
    await Future.delayed(const Duration(milliseconds: 500));

    // word not found
    if (result.isEmpty) {
      if (!(await connectedToInternet())) {
        if (mounted) {
          showFlushBar(
            context: context,
            message: 'Oops, no internet! Feel free to search your saved words.',
            type: MessageType.failure,
          );
        }
      } else {
        if (mounted) {
          showFlushBar(
            context: context,
            message: 'Oh no! We were not able to find this word :(',
            type: MessageType.failure,
          );
        }
      }

      setState(() {
        isSearching = false;
      });

      return;
    }

    if (mounted) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MeaningScreen(wordData: result),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation,
              alignment: const Alignment(0, 0.3),
              child: child,
            );
          },
        ),
      );
    }

    setState(() {
      isSearching = false;
    });

    FocusManager.instance.primaryFocus?.unfocus();
    searchController.clear();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      floatingActionButton: Align(
        alignment: const Alignment(0.9, 0.9),
        child: IconButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                reverseTransitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const BookmarksScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return ScaleTransition(
                    scale: animation,
                    alignment: const Alignment(0.7, 0.8),
                    child: child,
                  );
                },
              ),
            );
          },
          icon: const Icon(
            Icons.bookmark_rounded,
            size: 40,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/feather_pen_icon.png', height: 80),
            const SizedBox(height: 16),
            Text(
              "blurb.",
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontSize: 65,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
            const SizedBox(height: 34),
            !isSearching
                ? Column(
                    children: [
                      CustomSearchBar(
                        onSearchPressed: searchWord,
                        searchController: searchController,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTapDown: (details) {
                          setState(() {
                            borderWidth = 2;
                          });
                          HapticFeedback.selectionClick();
                        },
                        onTapUp: (details) async {
                          setState(() {
                            borderWidth = 6;
                          });
                          await Future.delayed(
                              const Duration(milliseconds: 200));
                          searchWord();
                        },
                        child: AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 50,
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 2.0, color: borderColor),
                              left: BorderSide(width: 2.0, color: borderColor),
                              right: BorderSide(width: 2.0, color: borderColor),
                              bottom: BorderSide(
                                  width: borderWidth, color: borderColor),
                            ),
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Search',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const ProgressBar()
          ],
        ),
      ),
    );
  }
}
