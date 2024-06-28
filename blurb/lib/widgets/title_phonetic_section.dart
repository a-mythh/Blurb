import 'package:flutter/material.dart';

class TitleAndPhoneticsSection extends StatelessWidget {
  final String word, phonetics;

  const TitleAndPhoneticsSection({
    required this.word,
    required this.phonetics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: Hero(
            tag: word,
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                word.toLowerCase(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        (phonetics.isNotEmpty
            ? FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  phonetics,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: const Color(0xFF4E4637),
                      ),
                ),
              )
            : const SizedBox.shrink())
      ],
    );
  }
}
