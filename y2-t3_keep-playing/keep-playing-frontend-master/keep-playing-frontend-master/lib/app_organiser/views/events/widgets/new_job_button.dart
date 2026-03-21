import 'package:flutter/material.dart';
import 'package:keep_playing_frontend/widgets/buttons.dart';

class NewJobButton extends FloatingActionButton {
  const NewJobButton({
    Key? key,
    required super.onPressed,
  }) : super.extended(
          key: key,
          extendedTextStyle: const TextStyle(fontSize: BUTTON_FONT_SIZE),
          tooltip: 'Increment',
          icon: const Icon(Icons.add),
          label: const Text("New Job"),
        );
}
