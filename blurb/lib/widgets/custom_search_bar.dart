import 'package:blurb/utility/autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function onSearchPressed;

  const CustomSearchBar({
    required this.searchController,
    required this.onSearchPressed,
    super.key,
  });

  Future<List<String>> getAutocompleteWords(String str) async {
    List<String> results = await AutocompleteAPI.search(str);

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 0,
              blurStyle: BlurStyle.outer,
            ),
          ],
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TypeAheadField(
          controller: searchController,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: (value) {
                onSearchPressed();
                focusNode.nextFocus();
              },
              decoration: InputDecoration(
                hintText: "Type your word...",
                hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondary
                        .withOpacity(0.8)),
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 22),
              textAlign: TextAlign.center,
              cursorRadius: const Radius.circular(10),
              cursorWidth: 3,
              enableIMEPersonalizedLearning: true,
              autocorrect: true,
              enableSuggestions: true,
              maxLines: 1,
            );
          },
          decorationBuilder: (context, child) => Material(
            type: MaterialType.card,
            color: Theme.of(context).colorScheme.primary,
            elevation: 4,
            borderRadius: BorderRadius.circular(26),
            child: child,
          ),
          itemBuilder: (context, word) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 26),
              title: Text(
                word,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          },
          itemSeparatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            thickness: 2,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.15),
          ),
          retainOnLoading: false,
          hideOnSelect: true,
          hideKeyboardOnDrag: true,
          hideOnUnfocus: true,
          hideOnEmpty: true,
          hideOnLoading: true,
          hideOnError: true,
          onSelected: (value) {
            searchController.text = value;
            HapticFeedback.selectionClick();
            onSearchPressed();
          },
          suggestionsCallback: getAutocompleteWords,
          debounceDuration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }
}
