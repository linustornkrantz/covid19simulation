import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  final double progress;
  ProgressScreen(this.progress);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        child: LinearProgressIndicator(value: progress),
      ),
    );
  }
}
