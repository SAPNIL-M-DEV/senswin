import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String errorValue) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error Occured"),
          content: Text(errorValue),
          actions: [
            FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"))
          ],
        );
      });
}
