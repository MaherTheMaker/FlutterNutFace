import 'package:TheNutFace/models/user.dart';
import 'package:TheNutFace/pages/edit_profile.dart';
import 'package:TheNutFace/pages/home.dart';
import 'package:TheNutFace/widgets/header.dart';
import 'package:TheNutFace/widgets/post.dart';
import 'package:TheNutFace/widgets/post_tile.dart';
import 'package:TheNutFace/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Profile extends StatefulWidget {
  Profile({this.userid});
  final String userid;
  @override
  _ProfileState createState() => _ProfileState();
}

String empty = "";

class _ProfileState extends State<Profile> {
  User user;
  final theCurrentUser = currentUser;
  bool isLoading = false;
  bool isLoadingPosts = false;
  bool grid = true;
  bool isfollowing = false;

  int followersCount = 0;
  int followingCount = 0;
  int postsCount = 0;
  List<Post> posts = [];

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.userid).get();
    user = User.fromDocument(doc);
    setState(() {
      isLoading = false;
    });
  }

  void getPosts() async {
    setState(() {
      isLoadingPosts = true;
    });
    QuerySnapshot snapshot = await postRef
        .document(widget.userid)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    final PP = snapshot.documents.map((e) => Post.fromdoc(e)).toList();
    setState(() {
      postsCount = snapshot.documents.length;
      posts = PP;
      isLoadingPosts = false;
    });
  }

  checkIsFollowing() async {
    DocumentSnapshot doc = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .document(widget.userid)
        .get();
    setState(() {
      isfollowing = doc.exists;
    });
  }

  getFollowersCount() async {
    QuerySnapshot doc = await followersRef
        .document(widget.userid)
        .collection("userFollowers")
        .getDocuments();
    setState(() {
      followersCount = doc.documents.length;
    });
  }

  getFollowingCount() async {
    QuerySnapshot doc = await followingRef
        .document(widget.userid)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingCount = doc.documents.length;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getUser();
    getPosts();
    checkIsFollowing();
    getFollowersCount();
    getFollowingCount();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context: context, text: 'Profile'),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                profilePage(),
                buildTogleGrid0rList(),
                buildPosts(),
              ],
            ),
    );
  }

  noProfilePage() {
    return Container(
      child: Center(child: Text("Profile deleted or don't exist")),
    );
  }

  profilePage() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
//          Center(child: Text(widget.user.fullName)),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GestureDetector(
                    child: Hero(
                      tag: 'profilePic',
                      child: CircleAvatar(
                        backgroundColor: Colors.white54,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                        radius: 50,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) {
                            return DetailScreen(url: user.photoUrl);
                          }));
                    }),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        BuildCount("Posts", postsCount),
                        BuildCount("Followers", followersCount),
                        BuildCount("Following", followingCount),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        BuildProfileBtn(),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  user.userName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.fullName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(user.bio),
              ],
            ),
          ),
          Divider(
            thickness: 2,
          ),
        ],
      ),
    );
  }

  BuildCount(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(
              color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
        ),
        Text(empty),
      ],
    );
  }

  handleUnFollowing() {
    setState(() {
      isfollowing = false;
    });
    followersRef
        .document(widget.userid)
        .collection('userFollowing')
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .document(widget.userid)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    feedRef
        .document(widget.userid)
        .collection('feedItems')
        .document(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowing() {
    setState(() {
      isfollowing = true;
    });
    followersRef
        .document(widget.userid)
        .collection('userFollowers')
        .document(currentUser.id)
        .setData({});

    followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .document(widget.userid)
        .setData({});
    feedRef
        .document(widget.userid)
        .collection('feedItems')
        .document(currentUser.id)
        .setData({
      "type": "Follow",
      "ownerId": widget.userid,
      "userId": currentUser.id,
      "username": currentUser.userName,
      "avatarUrl": currentUser.photoUrl,
      "timestamp": DateTime.now()
    });
  }

  BuildProfileBtn() {
    if (widget.userid == currentUser.id)
      return BuildBTn(label: "Edit Profile", fun: editProfile);
//      return buildButton(text: "EditProfile", function: () {});
    else if (isfollowing)
      return BuildBTn(label: "UnFollow", fun: handleUnFollowing);
    else if (!isfollowing)
      return BuildBTn(label: "Follow", fun: handleFollowing);
  }

  editProfile() async {
    String recived = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfile(
            currentUserId: currentUser.id,
          ),
        ));
    getUser();
  }

  BuildBTn({String label, Function fun}) {
    return Container(
      padding: EdgeInsets.only(top: 4),
      child: FlatButton(
        onPressed: fun,
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width / 2,
          height: 30,
          child: Text(
            label,
            style: TextStyle(
                color: isfollowing ? Colors.black : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500),
          ),
          decoration: BoxDecoration(
            color: isfollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
//        color: isfollowing ? Colors.white : Colors.blue,
      ),
    );
  }

  buildTogleGrid0rList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on, color: grid ? Colors.pink : Colors.grey),
          onPressed: () {
            setState(() {
              grid = true;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.list, color: !grid ? Colors.pink : Colors.grey),
          onPressed: () {
            setState(() {
              grid = false;
            });
          },
        )
      ],
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 220.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildPosts() {
    if (isLoadingPosts) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/upload.svg",
                height: 260,
              ),
              Text(
                "No Posts",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      );
    } else if (!grid)
      return Column(
        children: posts,
      );
    else {
      List<GridTile> gridList = [];
      posts.forEach((element) {
        gridList.add(GridTile(child: PostTile(pOstM: element.pOstM)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridList,
      );
    }
  }
}

class DetailScreen extends StatelessWidget {
  final String url;

  DetailScreen({this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12.withOpacity(.5),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'profilePic',
            child: CachedNetworkImage(
              imageUrl: url,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
