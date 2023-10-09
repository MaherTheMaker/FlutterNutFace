import 'package:TheNutFace/models/PostM.dart';
import 'package:TheNutFace/pages/home.dart';
import 'package:TheNutFace/widgets/header.dart';
import 'package:TheNutFace/widgets/post.dart';
import 'package:TheNutFace/widgets/progress.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId}) {
    print("in constractor postid=" + postId);
  }

  @override
  Widget build(BuildContext context) {
    print("userid $userId postid $postId");
    return FutureBuilder(
      future: postRef
          .document(userId)
          .collection('userPosts')
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        print(snapshot.data['postId']);
        POstM temp = POstM.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context: context, text: temp.caption, backbtn: true),
            body: ListView(
              children: <Widget>[
                Container(
                  child: Post(pOstM: temp),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
