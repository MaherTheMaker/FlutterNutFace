import 'package:cloud_firestore/cloud_firestore.dart';

class POstM {
  POstM(
      {this.postID,
      this.ownerId,
      this.userName,
      this.caption,
      this.location,
      this.photoUrl,
      this.timestamp,
      this.likes}) {
    print("in const " + postID);
    likesCounts = getLikesCount();
  }

  final String postID;
  final String ownerId;
  final String photoUrl;
  final String userName;
  final String location;
  final String caption;
  final dynamic timestamp;
  final Map likes;
  int likesCounts = 0;

  factory POstM.fromDocument(DocumentSnapshot doc) {
//    print("factory and postid = " + doc['postId']);
    return POstM(
      postID: doc['postId'],
      ownerId: doc['ownerId'],
      userName: doc['username'],
      photoUrl: doc['photoUrl'],
      caption: doc['caption'],
      location: doc['location'],
      likes: doc['likes'],
      timestamp: doc['timestamp'],
    );
  }
  int getLikesCount() {
    if (likes == null) return 0;
    int count = 0;
    likes.values.forEach((element) {
      if (element == true) count++;
    });
    print("count" + count.toString());
    return count;
  }
}
