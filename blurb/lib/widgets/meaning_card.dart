import 'package:another_flushbar/flushbar.dart';
import 'package:blurb/screens/meaning.dart';
import 'package:blurb/utility/internet_connection.dart';
import 'package:blurb/utility/progress_bar.dart';
import 'package:blurb/utility/search_words.dart';
import 'package:blurb/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class MeaningCard extends StatelessWidget {
  final String currentWord;
  final String meaning;
  final String? usage;

  const MeaningCard({
    required this.meaning,
    this.usage,
    required this.currentWord,
    super.key,
  });

  String getCapitalizedString(String usage) {
    usage = usage.trim();
    usage = usage[0].toUpperCase() + usage.substring(1);

    if (usage[usage.length - 1].contains(RegExp(r'[A-Za-z0-9]'))) {
      usage += '.';
    }

    return usage;
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(50),
            width: 160,
            height: 160,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                shape: BoxShape.rectangle),
            child: const ProgressBar(),
          ),
        );
      },
    );
  }

  void searchWord(BuildContext context, String word) async {
    // check for empty text
    if (word.isEmpty) {
      showFlushBar(
        context: context,
        message: 'Invalid search query.',
        type: MessageType.failure,
      );
      debugPrint("Invalid Word.");
      return;
    }

    if (currentWord.toLowerCase() == word.toLowerCase()) {
      showFlushBar(
        context: context,
        message: 'No, no. Don\'t do that.',
        type: MessageType.failure,
      );
      debugPrint("Can't search for the same word");
      return;
    }

    if (context.mounted) {
      showFlushBar(
        context: context,
        message: 'Searching...',
        type: MessageType.normal,
        position: FlushbarPosition.TOP,
        duration: const Duration(seconds: 10),
      );
    }

    Map result = await Dictionary().searchWord(word);

    await Future.delayed(const Duration(milliseconds: 1000));

    // word not found
    if (result.isEmpty) {
      if (!(await connectedToInternet())) {
        if (context.mounted) {
          showFlushBar(
            context: context,
            message: 'Oops, no internet! Feel free to search your saved words.',
            type: MessageType.failure,
          );
        }
      } else {
        if (context.mounted) {
          showFlushBar(
            context: context,
            message: 'Oh no! We were not able to find this word :(',
            type: MessageType.failure,
          );
        }
      }

      return;
    }

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MeaningScreen(wordData: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedText = "";

    // meaning
    Widget meaningWidget = Text(
      meaning.trim(),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge,
    );

    // usage
    Widget usageWidget = (usage != null && usage!.trim().isNotEmpty
        ? Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            child: Text(
              getCapitalizedString(usage!),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.85),
                  ),
            ),
          )
        : // return empty widget if there is no usage available
        const SizedBox.shrink());

    return OverflowBox(
      maxWidth: MediaQuery.of(context).size.width - 30,
      maxHeight: 400,
      child: StatefulBuilder(
        builder: (context, setState) {
          return SelectionArea(
            onSelectionChanged: (value) {
              setState(() {
                selectedText = value != null ? value.plainText : "";
              });
            },
            contextMenuBuilder: (context, selectableRegionState) {
              final List<ContextMenuButtonItem> buttonItems =
                  selectableRegionState.contextMenuButtonItems;

              // search blurb option
              buttonItems.add(
                ContextMenuButtonItem(
                  onPressed: () => searchWord(context, selectedText),
                  label: 'Search blurb',
                  type: ContextMenuButtonType.custom,
                ),
              );

              return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: buttonItems,
                anchors: selectableRegionState.contextMenuAnchors,
              );
            },
            child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 0,
                        blurStyle: BlurStyle.outer,
                      ),
                    ]),
                child: Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: RawScrollbar(
                    thumbColor: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.2),
                    thickness: 5,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          meaningWidget,
                          const SizedBox(height: 14),
                          usageWidget,
                        ],
                      ),
                    ),
                  ),
                )),
          );
        },
      ),
    );
  }
}
