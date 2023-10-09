import 'package:TheNutFace/models/PostM.dart';
import 'package:TheNutFace/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final POstM pOstM;

  const PostTile({this.pOstM});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("showing post"),
      child: cachedNetworkImage(pOstM.photoUrl),
    );
  }
}
