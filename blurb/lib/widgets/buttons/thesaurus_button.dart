import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThesaurusButton extends StatefulWidget {
  final String thesaurusType;
  final List<String> thesaurus;

  const ThesaurusButton({
    required this.thesaurusType,
    required this.thesaurus,
    super.key,
  });

  @override
  State<ThesaurusButton> createState() => _ThesaurusButtonState();
}

class _ThesaurusButtonState extends State<ThesaurusButton> {
  double _borderWidth = 6.0;

  void showThesaurus(String thesaurusType, List<String> thesaurus) {
    String combinedString = thesaurus.join(', ');

    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      context: context,
      builder: (context) {
        return IntrinsicHeight(
          child: Container(
            constraints: const BoxConstraints(minHeight: 200),
            child: Center(
                child: Column(
              children: [
                Text(thesaurusType,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 22)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 20,
                  ),
                  child: Text(
                    combinedString,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            )),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondary;

    return GestureDetector(
      onTapDown: (details) {
        setState(
          () {
            _borderWidth = 2;
          },
        );
        HapticFeedback.selectionClick();
      },
      onTapUp: (details) async {
        setState(() {
          _borderWidth = 6;
        });
        await Future.delayed(const Duration(milliseconds: 200));
        showThesaurus(
          widget.thesaurusType,
          widget.thesaurus,
        );
      },
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 46,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 2.0, color: borderColor),
            left: BorderSide(width: 2.0, color: borderColor),
            right: BorderSide(width: 2.0, color: borderColor),
            bottom: BorderSide(width: _borderWidth, color: borderColor),
          ),
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(18),
        ),
        duration: const Duration(milliseconds: 150),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.thesaurusType,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
          ),
        ),
      ),
    );
  }
}
