import 'package:flutter/material.dart';

class PartOfSpeechButton extends StatelessWidget {
  final String partOfSpeech;
  final bool active;
  final VoidCallback onPressed;

  const PartOfSpeechButton({
    super.key,
    required this.partOfSpeech,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 18,
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          active
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        partOfSpeech.toLowerCase(),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 20,
              letterSpacing: 1.2,
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
              height: 1,
            ),
      ),
    );
  }
}
