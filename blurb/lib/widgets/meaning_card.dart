import 'package:flutter/material.dart';

class MeaningCard extends StatelessWidget {
  final String meaning;
  final String? usage;

  const MeaningCard({
    required this.meaning,
    this.usage,
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

  @override
  Widget build(BuildContext context) {
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
      child: SelectionArea(
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
                thumbColor:
                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
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
      ),
    );
  }
}
