import 'package:flutter/material.dart';

header({context, bool isapptitle = false, String text, bool backbtn = false}) {
  return AppBar(
    backgroundColor: Theme.of(context).primaryColorLight,
    automaticallyImplyLeading: backbtn,
    centerTitle: true,
    title: isapptitle
        ? Text(
            'The NutFace',
            style: TextStyle(
              fontSize: 50,
              fontFamily: 'Signatra',
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          )
        : Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
            ),
            overflow: TextOverflow.ellipsis,
          ),
  );
}
