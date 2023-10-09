import 'dart:async';

import 'package:TheNutFace/models/PostM.dart';
import 'package:TheNutFace/models/user.dart';
import 'package:TheNutFace/pages/comments.dart';
import 'package:TheNutFace/pages/home.dart';
import 'package:TheNutFace/widgets/custom_image.dart';
import 'package:TheNutFace/widgets/progress.dart';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  final POstM pOstM;

  Post({this.pOstM});

  factory Post.fromdoc(DocumentSnapshot doc) {
    POstM pOstM = POstM.fromDocument(doc);
    return Post(
      pOstM: pOstM,
    );
  }
  @override
  _PostState createState() => _PostState(pOstM);
}

class _PostState extends State<Post> {
  _PostState(this.pOstM);
  POstM pOstM;
  User user;
  bool isloading = false;
  bool isLiked;
  final currentuserid = currentUser.id;
  bool showHeart = false;
  getinfo() async {
    print("in header");
    setState(() {
      isloading = true;
    });

    DocumentSnapshot doc = await userRef.document(pOstM.ownerId).get();
    user = User.fromDocument(doc);
    setState(() {
      isloading = false;
    });
  }

  showComments() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Comments(
            postId: pOstM.postID,
            mediaUrl: pOstM.photoUrl,
            ownerId: pOstM.ownerId,
          ),
        ));
  }

  postHeader() {
    return ListTile(
      leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          backgroundColor: Colors.grey),
      title: GestureDetector(
        onTap: () => print("showing profile"),
        child: Text(
          user.fullName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      subtitle: Text(pOstM.location),
      trailing: IconButton(
        onPressed: () => print('deleting post'),
        icon: Icon(Icons.more_vert),
      ),
    );
  }

//  buildPostHeader() {
//    return FutureBuilder(
//      future: userRef.document(pOstM.ownerId).get(),
//      builder: (context, snapshot) {
//        if (!snapshot.hasData) {
//          return circularProgress();
//        }
//        User user = User.fromDocument(snapshot.data);
//        return ListTile(
//          leading: CircleAvatar(
//            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
//            backgroundColor: Colors.grey,
//          ),
//          title: GestureDetector(
//            onTap: () => print('showing profile'),
//            child: Text(
//              user.userName,
//              style: TextStyle(
//                color: Colors.black,
//                fontWeight: FontWeight.bold,
//              ),
//            ),
//          ),
//          subtitle: Text(pOstM.location),
//          trailing: IconButton(
//            onPressed: () => print('deleting post'),
//            icon: Icon(Icons.more_vert),
//          ),
//        );
//      },
//    );
//  }

  addliketofeeds() {
    bool isNotPostowner = pOstM.ownerId != currentUser.id;
    if (isNotPostowner) {
      feedRef
          .document(pOstM.ownerId)
          .collection('feedItems')
          .document(pOstM.postID)
          .setData({
        'type': 'Like',
        'username': currentUser.userName,
        'userId': currentuserid,
        'postId': pOstM.postID,
        'avatarUrl': currentUser.photoUrl,
        'timestamp': DateTime.now(),
        'mediaUrl': pOstM.photoUrl,
      });
    }
  }

  removelikefromfeeds() {
    bool isNotPostowner = pOstM.ownerId != currentUser.id;
    if (isNotPostowner) {
      feedRef
          .document(pOstM.ownerId)
          .collection('feedItems')
          .document(pOstM.postID)
          .get()
          .then((doc) {
        if (doc.exists) doc.reference.delete();
      });
    }
  }

  handleLikes() {
    bool _isliked = (pOstM.likes[currentuserid] == true);
    print(_isliked.toString() + "____" + currentUser.toString());
    print(pOstM.likes);
    if (_isliked) {
      postRef
          .document(pOstM.ownerId)
          .collection("userPosts")
          .document(pOstM.postID)
          .updateData({'likes.$currentuserid': false});
      removelikefromfeeds();
      setState(() {
        isLiked = false;
        pOstM.likesCounts--;
        pOstM.likes[currentuserid] = false;
      });
    } else {
      postRef
          .document(pOstM.ownerId)
          .collection("userPosts")
          .document(pOstM.postID)
          .updateData({'likes.$currentuserid': true});
      addliketofeeds();
      setState(() {
        showHeart = true;
        isLiked = true;
        pOstM.likesCounts++;
        pOstM.likes[currentuserid] = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  postImage() {
    print("in photo");

    return GestureDetector(
      onDoubleTap: handleLikes,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(pOstM.photoUrl),
          showHeart
              ? Animator<double>(
                  tween: Tween<double>(begin: .5, end: 1.5),
                  cycles: 0,
                  builder: (context, animatorState, child) => Transform.scale(
                        scale: animatorState.value,
                        child: Icon(
                          Icons.favorite,
                          size: 60,
                          color: Colors.pink,
                        ),
                      ))
              : Text(""),
        ],
      ),
    );
  }

  postFooter() {
    print("in footer");
    final o = timeago.format(pOstM.timestamp.toDate());
    print(o);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.pink,
              ),
              onPressed: handleLikes,
            ),
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: Colors.blue[900],
              ),
              onPressed: () => showComments(),
            ),
          ],
        ),
        pOstM.likesCounts < 1
            ? Divider(
                color: Colors.white,
                thickness: 0,
                height: 0,
              )
            : Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      "${pOstM.likesCounts} likes",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 12.0),
              child: Text(
                "${pOstM.userName} ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(o.toString()))
          ],
        ),
        Divider(
          height: 20.0,
          thickness: 20,
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfo();
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (pOstM.likes[currentuserid] == true);
    return isloading
        ? circularProgress()
        : Column(
            children: <Widget>[
              postHeader(),
              postImage(),
              postFooter(),
            ],
          );
  }
}
