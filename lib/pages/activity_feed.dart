import 'package:TheNutFace/pages/home.dart';
import 'package:TheNutFace/pages/post_screen.dart';
import 'package:TheNutFace/pages/profile.dart';
import 'package:TheNutFace/widgets/header.dart';
import 'package:TheNutFace/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  final userID = currentUser.id;
  getActivityfeeds() {
    final docs = feedRef
        .document(userID)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
    return docs;
  }

  @override
  Widget build(BuildContext context) {
    getActivityfeeds();
    return Scaffold(
      appBar: header(context: context, text: "ActivityFeed"),
      body: StreamBuilder(
        stream: getActivityfeeds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<ActivityFeedItem> listy = [];

          snapshot.data.documents.forEach((element) {
            listy.add(ActivityFeedItem.formDoc(element));
          });
          return ListView(
            children: listy,
          );
        },
      ),
    );
  }
}

Widget previewImage;
String contectx;

class ActivityFeedItem extends StatelessWidget {
  final String userId;
  final String username;
  final String type;
  final String mediaurl;
  //TODO fix post id
  final String postId;

  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem(
      {this.userId,
      this.username,
      this.type,
      this.mediaurl,
      this.postId,
      this.userProfileImg,
      this.commentData,
      this.timestamp});

  configuer(context) {
    if (type == "Like" || type == "Comment") {
      previewImage = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(mediaurl)),
              ),
            ),
          ),
        ),
      );
    } else {
      previewImage = Text("");
    }
    if (type == "Like") {
      contectx = " liked your post";
    } else if (type == "Comment") {
      contectx = " commented : $commentData ";
    } else if (type == "Follow") {
      contectx = " is following you";
    } else {
      contectx = " Error unknown type $type";
    }
  }

  factory ActivityFeedItem.formDoc(DocumentSnapshot doc) {
    print(doc['postId']);
    return ActivityFeedItem(
        userId: doc['userId'],
        type: doc['type'],
        timestamp: doc['timestamp'],
        username: doc['username'],
        userProfileImg: doc['avatarUrl'],
        postId: doc['postId']?.toString(),
        mediaurl: doc['mediaUrl'],
        commentData: doc['commentData']?.toString());
  }
  @override
  Widget build(BuildContext context) {
    configuer(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(userid: userId),
                )),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                        style: TextStyle(fontWeight: FontWeight.bold),
                        text: "$username"),
                    TextSpan(text: contectx),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: previewImage,
        ),
      ),
    );
  }

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: postId,
                  userId: currentUser.id,
                )));
  }
}
//'type': 'Comment',
//'commentData': CommentController.text,
//'username': currentUser.userName,
//'userId': widget.ownerId,
//'postId': postId,
//'avatarUrl': currentUser.photoUrl,
//'timestamp': DateTime.now(),
//'mediaUrl': widget.mediaUrl,
//});
