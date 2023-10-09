import 'package:TheNutFace/models/user.dart';
import 'package:TheNutFace/models/PostM.dart';
import 'package:TheNutFace/pages/activity_feed.dart';
import 'package:TheNutFace/pages/create_account.dart';
import 'package:TheNutFace/pages/profile.dart';
import 'package:TheNutFace/pages/search.dart';
import 'package:TheNutFace/pages/timeline.dart';
import 'package:TheNutFace/pages/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

final googleSignIn = GoogleSignIn();
final storageRef = FirebaseStorage.instance.ref();
bool isAuth = false;
final userRef = Firestore.instance.collection('users');
final postRef = Firestore.instance.collection('posts');
final commentRef = Firestore.instance.collection('comments');
final feedRef = Firestore.instance.collection('feeds');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');

final timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController;

  int pageIndex = 2;
  login() {
    googleSignIn.signIn().catchError((_) {
      print("error logging in");
      Fluttertoast.showToast(
          msg: " Error logging in , Please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  Future<void> handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserFireStore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  Future<void> createUserFireStore() async {
    final user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();
    if (!doc.exists) {
      final String username = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateAccount(),
          ));
      userRef.document(user.id).setData({
        'id': user.id,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'username': username,
        'fullname': user.displayName,
        'bio': '',
        'timestamp': timestamp,
      });
      doc = await userRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser.photoUrl);
  }

  Future<void> haha() async {
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) async {
      await handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
      Fluttertoast.showToast(
          msg: " Error logging in , Please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
    print('im the mother fucker code');
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
      Fluttertoast.showToast(
          msg: " Error logging in , Please try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  void initState() {
    print(timestamp);
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: 2);
    haha();
//    testpostM();
  }

  testpostM() async {
    DocumentSnapshot doc = await postRef
        .document('102786694678590726787')
        .collection("userPosts")
        .document("32ae71bc-097e-49a0-88d2-1e87d86ce686")
        .get();
    POstM postm = POstM.fromDocument(doc);
    print(postm.postID);
  }

  Widget buildUnAuth() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).primaryColorLight,
            Theme.of(context).accentColor
          ],
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'The Nut Face',
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 60,
                  fontFamily: 'Signatra'),
            ),
            GestureDetector(
                child: Container(
                  width: 260,
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          AssetImage('assets/images/google_signin_button.png'),
                    ),
                  ),
                ),
                onTap: login)
          ],
        ),
      ),
    );
  }

  Widget buildAuth() {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          children: <Widget>[
            Timeline(),
            ActivityFeed(),
            Upload(currentUser: currentUser),
            Search(),
            Profile(
              userid: currentUser.id,
            ),
          ],
          controller: pageController,
          onPageChanged: onPageChange,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.whatshot,
                size: 35,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications_active,
                size: 35,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_camera,
                size: 35,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 35,
              ),
            ),
            BottomNavigationBarItem(
                icon: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuth() : buildUnAuth();
  }

  void onPageChange(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  void onTap(int pageIndex) {
    setState(() {
      pageController.animateToPage(pageIndex,
          duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
    });
  }
}
