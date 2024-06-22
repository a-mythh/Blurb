import 'package:blurb/screens/bookmarks.dart';
import 'package:flutter/material.dart';

// screens
import 'package:blurb/screens/meaning.dart';

// widgets
import 'package:blurb/widgets/custom_search_bar.dart';

// utility
import 'package:blurb/utility/search_words.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // controllers
  final searchController = TextEditingController();
  Dictionary dictionary = Dictionary();

  double borderWidth = 6.0;

  void searchWord() async {
    String word = searchController.text.trim().toLowerCase();

    // check for empty text
    if (word.isEmpty) {
      print("Invalid Word.");
      searchController.text = "";
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    Map result = await dictionary.searchWord(word);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MeaningScreen(wordData: result),
        ),
      );
    }

    searchController.text = "";
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
      floatingActionButton: IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const BookmarksScreen(),
          ));
        },
        icon: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 40,
            horizontal: 20,
          ),
          child: const Icon(
            Icons.bookmark_rounded,
            size: 40,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
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
            CustomSearchBar(
              onSearchPressed: searchWord,
              searchController: searchController,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTapDown: (details) => setState(() {
                borderWidth = 2;
              }),
              onTapUp: (details) async {
                setState(() {
                  borderWidth = 6;
                });
                await Future.delayed(const Duration(milliseconds: 200));
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
                    bottom: BorderSide(width: borderWidth, color: borderColor),
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
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
