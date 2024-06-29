import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

enum MessageType {
  normal,
  success,
  failure,
}

Map<MessageType, List<Color>> colour = {
  MessageType.normal: [
    const Color(0xFF4E4637),
    const Color(0xFFF1E5D1),
  ],
  MessageType.success: [
    const Color(0xFFA5DD9B),
    const Color(0xFF352F25),
  ],
  MessageType.failure: [
    const Color(0xFFFF8080),
    const Color(0xFF352F25),
  ]
};

SnackBar getSnackBar({
  required BuildContext context,
  required String message,
  required MessageType type,
}) {
  return SnackBar(
    duration: const Duration(milliseconds: 1000),
    backgroundColor: colour[type]![0],
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: colour[type]![1],
          ),
    ),
  );
}

void showFlushBar({
  required BuildContext context,
  required String message,
  FlushbarPosition position = FlushbarPosition.BOTTOM,
  Duration duration = const Duration(seconds: 3),
  required MessageType type,
}) {
  Flushbar(
    messageText: Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: colour[type]![1],
          ),
    ),
    maxWidth: 250,
    margin: position == FlushbarPosition.TOP
        ? const EdgeInsets.only(top: 50)
        : const EdgeInsets.only(bottom: 30),
    backgroundColor: colour[type]![0],
    duration: duration,
    animationDuration: const Duration(milliseconds: 400),
    flushbarPosition: position,
    flushbarStyle: FlushbarStyle.FLOATING,
    borderRadius: BorderRadius.circular(14),
    isDismissible: true,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    blockBackgroundInteraction: false,
  ).show(context);
}
