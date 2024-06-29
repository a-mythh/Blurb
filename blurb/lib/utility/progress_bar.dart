import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Theme.of(context).colorScheme.onPrimary,
      strokeCap: StrokeCap.round,
      strokeWidth: 8,
    );
  }
}
