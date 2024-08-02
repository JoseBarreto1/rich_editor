import 'package:flutter/material.dart';

class PrettyWidget extends StatelessWidget {
  const PrettyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("I'm the widget in the box"),
    );
  }
}
