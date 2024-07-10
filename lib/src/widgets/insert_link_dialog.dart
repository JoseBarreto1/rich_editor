import 'package:flutter/material.dart';

import 'custom_dialog_template.dart';

class InsertLinkDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController link = TextEditingController();
    TextEditingController label = TextEditingController();
    return CustomDialogTemplate(
      body: [
        Text('Link'),
        TextField(
          controller: link,
          decoration: InputDecoration(
            hintText: 'type link here',
          ),
        ),
        SizedBox(height: 20.0),
        Text('Label'),
        TextField(
          controller: label,
          decoration: InputDecoration(
            hintText: 'type label text here',
          ),
        ),
      ],
      onDone: () => Navigator.pop(context, [link.text, label.text]),
      onCancel: () => Navigator.pop(context),
    );
  }
}
