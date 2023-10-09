import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    padding: EdgeInsets.only(top: 10.0),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}

linearProgress() {
  return Container(
    padding: EdgeInsets.only(top: 2.0),
    alignment: Alignment.center,
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.pink),
    ),
  );
}
