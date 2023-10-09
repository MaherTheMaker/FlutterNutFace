import 'package:TheNutFace/widgets/header.dart';
import 'package:TheNutFace/widgets/progress.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context: context, isapptitle: true),
      body: circularProgress(),
    );
  }
}
