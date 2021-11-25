import 'dart:io';

import 'package:blur_chat/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../size_config.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  ChatRoom({Key? key, required this.userMap, required this.chatRoomId})
      : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sentBy": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      // ignore: avoid_print
      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sentBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      // ignore: avoid_print
      print("Enter some text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            SizedBox(width: getPropScreenWidth(10)),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(userMap['uid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userMap['name'],
                          style: BlurChatTheme.darkTextTheme.headline2,
                        ),
                        Text(
                          snapshot.data!['status'],
                          style: BlurChatTheme.darkTextTheme.bodyText2,
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(Icons.phone, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(chatRoomId)
                  .collection('chats')
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data != null) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> map = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;

                      return messages(map, context);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: SizeConfig.screenHeight! * 0.06,
                width: SizeConfig.screenWidth! * 0.8,
                child: TextField(
                  controller: _message,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () => getImage(),
                      icon: const Icon(Icons.camera_outlined),
                    ),
                    hintText: "Type a message",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    enabledBorder: outlineInputBorder(context),
                    focusedBorder: outlineInputBorder(context),
                    border: outlineInputBorder(context),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSendMessage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).indicatorColor),
                  ),
                  child: Icon(Icons.send,
                      size: 23, color: Theme.of(context).indicatorColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget messages(Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            width: SizeConfig.screenWidth!,
            alignment: map['sentBy'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: map['sentBy'] == _auth.currentUser!.displayName
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                map['sentBy'] == _auth.currentUser!.displayName
                    ? Container()
                    : const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 15, color: Colors.black),
                      ),
                SizedBox(width: getPropScreenWidth(7)),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: map['sentBy'] == _auth.currentUser!.displayName
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).shadowColor,
                  ),
                  child: Text(
                    map['message'],
                    style: map['sentBy'] == _auth.currentUser!.displayName
                        ? BlurChatTheme.darkTextTheme.headline4
                        : Theme.of(context).textTheme.headline4,
                  ),
                ),
              ],
            ),
          )
        : Container(
            height: SizeConfig.screenHeight! * 0.34,
            width: SizeConfig.screenWidth,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sentBy'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ShowImage(
                  imageUrl: map['message'],
                ),
              )),
              child: Container(
                height: SizeConfig.screenHeight! * 0.32,
                width: SizeConfig.screenWidth! * 0.6,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          map['message'],
                          fit: BoxFit.contain,
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          );
  }

  OutlineInputBorder outlineInputBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Theme.of(context).indicatorColor),
      gapPadding: 10,
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;
  const ShowImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
