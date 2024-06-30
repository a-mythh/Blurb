import 'dart:async';

import 'package:blurb/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late Timer timer;
  int index = 0;

  void runAnimations() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (index < 10) {
        setState(() {
          index++;
        });
      }

      if (index == 10) {
        timer.cancel();

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool('seenIntro', true);

        Future.delayed(
          const Duration(seconds: 6),
          () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 900),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    runAnimations();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle fontStyle = TextStyle(
      fontSize: 24,
      fontFamily: 'Comics Sans',
      color: Theme.of(context).colorScheme.onPrimary,
    );
    List<Widget> widgets = [
      Text(
        'Hey there!',
        key: const ValueKey<int>(1),
        style: fontStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'You know how life sometimes throws these random vocab gems at us, right?',
        key: const ValueKey<int>(2),
        style: fontStyle.copyWith(height: 2),
        textAlign: TextAlign.center,
      ),
      Text(
        'You learn a new word, and suddenly you\'re all \n\'Whoa, I\'ll use it next time\'.',
        key: const ValueKey<int>(132),
        style: fontStyle.copyWith(height: 2),
        textAlign: TextAlign.center,
      ),
      Text(
        'And then... you forget it.\n\nYeah happens with me too.',
        key: const ValueKey<int>(3),
        style: fontStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'So I made this.\n(for myself mostly)',
        key: const ValueKey<int>(234),
        style: fontStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        'Here\'s how you can use it...',
        key: const ValueKey<int>(245),
        style: fontStyle,
        textAlign: TextAlign.center,
      ),
      Column(
        key: const ValueKey<int>(5),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Text(
              '1',
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Search for your word.',
            textAlign: TextAlign.center,
            style: fontStyle,
          ),
        ],
      ),
      Column(
        key: const ValueKey<int>(6),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Text(
              '2',
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Swipe the cards to view meanings.',
            textAlign: TextAlign.center,
            style: fontStyle,
          ),
        ],
      ),
      Column(
        key: const ValueKey<int>(7),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Text(
              '3',
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Save to view offline.',
            textAlign: TextAlign.center,
            style: fontStyle,
          ),
        ],
      ),
      Text(
        key: const ValueKey<int>(8),
        'Yeah,\nthat\'s it.',
        style: fontStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        key: const ValueKey<int>(9),
        'And remember\nwhen life gives you lemons,\nsquirt them into your eyes.',
        style: fontStyle.copyWith(height: 2),
        textAlign: TextAlign.center,
      ),
    ];

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: AnimatedSwitcher(
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 700),
                  reverseDuration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity:
                          Tween<double>(begin: 0, end: 1).animate(animation),
                      child: child,
                    );
                  },
                  child: widgets[index],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
