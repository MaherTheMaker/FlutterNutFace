import 'package:TheNutFace/pages/home.dart';
import 'package:TheNutFace/widgets/header.dart';
import 'package:TheNutFace/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String mediaUrl;

  Comments({this.postId, this.ownerId, this.mediaUrl});

  @override
  CommentsState createState() =>
      CommentsState(postId: postId, mediaUrl: mediaUrl, ownerId: ownerId);
}

class CommentsState extends State<Comments> {
  final String postId;
  final String ownerId;
  final String mediaUrl;

  TextEditingController CommentController = TextEditingController();

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: commentRef
          .document(postId)
          .collection('comments')
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> whatever = [];
        snapshot.data.documents.forEach((element) {
          whatever.add(Comment(
            vart: CommentM.fromDoc(element),
          ));
        });
        return Expanded(
          child: ListView(
//            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: whatever,
          ),
        );
      },
    );
  }

  CommentsState({this.postId, this.ownerId, this.mediaUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
            flex: 1,
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: CommentController,
              decoration: InputDecoration(labelText: "Write a comment:"),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              color: Colors.grey,
              child: Text("post"),
            ),
          )
        ],
      ),
    );
  }

  void addComment() {
    commentRef.document(postId).collection('comments').add({
      "username": currentUser.userName,
      "comment": CommentController.text,
      "timestamp": DateTime.now(),
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
    print(widget.ownerId);
    bool isNotPostowner = widget.ownerId != currentUser.id;
    if (isNotPostowner) {
      feedRef.document(widget.ownerId).collection('feedItems').add({
        'type': 'Comment',
        'commentData': CommentController.text,
        'username': currentUser.userName,
        'userId': currentUser.id,
        'postId': postId,
        'avatarUrl': currentUser.photoUrl,
        'timestamp': DateTime.now(),
        'mediaUrl': widget.mediaUrl,
      });
    }
    CommentController.clear();
  }
}

class Comment extends StatelessWidget {
  final CommentM vart;

  const Comment({this.vart});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(vart.Comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(vart.photoUrl),
          ),
          subtitle: Text(timeago.format(vart.timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}

class CommentM {
  final String username;
  final String userId;
  final String Comment;
  final String photoUrl;
  final Timestamp timestamp;

  CommentM(
      {this.username,
      this.userId,
      this.photoUrl,
      this.Comment,
      this.timestamp});
  factory CommentM.fromDoc(DocumentSnapshot doc) {
    return CommentM(
        username: doc['username'],
        userId: doc['userId'],
        photoUrl: doc['avatarUrl'],
        Comment: doc['comment'],
        timestamp: doc['timestamp']);
  }
}
