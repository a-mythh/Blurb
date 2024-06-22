import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function onSearchPressed;

  const CustomSearchBar({
    required this.searchController,
    required this.onSearchPressed,
    super.key,
  });

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
        child: TextField(
          onSubmitted: (value) => onSearchPressed(),
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Type your word...",
            hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                color:
                    Theme.of(context).colorScheme.onSecondary.withOpacity(0.8)),
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSecondary, fontSize: 22),
          textAlign: TextAlign.center,
          cursorRadius: const Radius.circular(10),
          cursorWidth: 3,
          enableIMEPersonalizedLearning: true,
          autocorrect: true,
          enableSuggestions: true,
          maxLines: 1,
        ),
      ),
    );
  }
}
