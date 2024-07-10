import 'package:flutter/material.dart';

import 'custom_dialog_template.dart';

class CheckDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController text = TextEditingController();
    return CustomDialogTemplate(
      body: [
        Text('Checkbox title'),
        TextField(
          controller: text,
          decoration: InputDecoration(hintText: ''),
        ),
      ],
      onDone: () => Navigator.pop(context, text.text),
      onCancel: () => Navigator.pop(context),
    );
  }
}
