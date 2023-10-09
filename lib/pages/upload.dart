import 'dart:io';

import 'package:TheNutFace/models/user.dart';
import 'package:TheNutFace/pages/home.dart';
import 'package:TheNutFace/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

class Upload extends StatefulWidget {
  final User currentUser;

  const Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  String postID = Uuid().v4();
  bool isUploading = false;
  TextEditingController captionCtrl = TextEditingController();
  TextEditingController locationCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplash() : uploadForm();
  }

  Container buildSplash() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "assets/images/upload.svg",
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  "Upload",
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),
                color: Colors.blueAccent,
                onPressed: () => selectPic(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  selectPic(ParentContext) {
    return showDialog(
      context: ParentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Chosse From"),
          children: <Widget>[
            SimpleDialogOption(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Gallery"),
                  Icon(Icons.photo),
                ],
              ),
              onPressed: () async {
                Navigator.pop(context);
                File temp =
                    await ImagePicker.pickImage(source: ImageSource.gallery);
                setState(() {
                  file = temp;
                });
              },
            ),
            SimpleDialogOption(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Camera"),
                  Icon(Icons.photo_camera),
                ],
              ),
              onPressed: () async {
                Navigator.pop(context);
                File temp = await ImagePicker.pickImage(
                    source: ImageSource.camera, maxHeight: 900, maxWidth: 600);
                setState(() {
                  file = temp;
                });
              },
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  uploadForm() {
    print(timestamp);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white54,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: clearImage),
        title: Text(
          "Create Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: isUploading ? null : () => HandleSubmit(),
              child: Text(
                "Post",
                style: TextStyle(
                    color: isUploading ? Colors.grey : Colors.blueAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ))
        ],
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * .8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: FileImage(file))),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionCtrl,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Write your Post",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationCtrl,
                decoration: InputDecoration(
                  hintText: "Location",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.blue,
              onPressed: getLocation,
              icon: Icon(Icons.my_location),
              label: Text(
                "Current Loacation",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    file = null;
    Navigator.pop(context);
  }

  getLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarkers = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    print(placeMarkers[0].locality);
    locationCtrl.text = placeMarkers[0].locality;
  }

  compresImage() async {
    Directory dirtemp = await getTemporaryDirectory();
    String path = dirtemp.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postID.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  HandleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compresImage();
    String photourl = await upladeImage(file);
    await createPostInFireStore(
        photourl: photourl,
        caption: captionCtrl.text,
        location: locationCtrl.text);
    captionCtrl.clear();
    locationCtrl.clear();
    setState(() {
      file = null;
      isUploading = false;
    });
    postID = Uuid().v4();
  }

  Future<String> upladeImage(imageFile) async {
    StorageUploadTask sutask =
        storageRef.child("post_$postID.jpg").putFile(imageFile);
    StorageTaskSnapshot snapshot = await sutask.onComplete;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  createPostInFireStore({String photourl, String caption, String location}) {
    postRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postID)
        .setData({
      "postId": postID,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.userName,
      "photoUrl": photourl,
      "caption": caption,
      "location": location,
      "timestamp": DateTime.now(),
      "likes": {},
    });
  }
}
