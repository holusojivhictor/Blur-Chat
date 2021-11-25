import 'dart:io';

import 'package:blur_chat/ui/singles_chat_room/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../size_config.dart';
import '../../theme.dart';
import 'group_info.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;
  GroupChatRoom({Key? key, required this.groupName, required this.groupChatId})
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
        .collection('groups')
        .doc(groupChatId)
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
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      // ignore: avoid_print
      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sentBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            SizedBox(width: getPropScreenWidth(10)),
            Text(
              groupName,
              style: BlurChatTheme.darkTextTheme.headline2,
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => GroupInfo(
                          groupName: groupName,
                          groupId: groupChatId,
                        )),
              );
            },
            icon: Icon(Icons.more_vert, color: Theme.of(context).canvasColor),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(groupChatId)
                  .collection('chats')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> chatMap = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;

                      return messageTile(size, chatMap, context);
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
                  child:
                      Icon(Icons.send, color: Theme.of(context).indicatorColor),
                ),
              ),
            ],
          ),
        ],
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

  Widget messageTile(
      Size size, Map<String, dynamic> chatMap, BuildContext context) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          width: SizeConfig.screenWidth,
          alignment: chatMap['sentBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                chatMap['sentBy'] == _auth.currentUser!.displayName
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              chatMap['sentBy'] == _auth.currentUser!.displayName
                  ? Container()
                  : const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 15, color: Colors.black),
                    ),
              SizedBox(width: getPropScreenWidth(7)),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: chatMap['sentBy'] == _auth.currentUser!.displayName
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).shadowColor,
                ),
                child: Column(
                  crossAxisAlignment:
                      chatMap['sentBy'] == _auth.currentUser!.displayName
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatMap['sentBy'],
                      style: chatMap['sentBy'] == _auth.currentUser!.displayName
                          ? BlurChatTheme.darkTextTheme.bodyText1
                          : Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(height: getPropScreenHeight(3)),
                    Text(
                      chatMap['message'],
                      style: chatMap['sentBy'] == _auth.currentUser!.displayName
                          ? BlurChatTheme.darkTextTheme.headline4
                          : Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          height: SizeConfig.screenHeight! * 0.34,
          width: SizeConfig.screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          alignment: chatMap['sentBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => ShowImage(imageUrl: chatMap['message'])),
            ),
            child: Container(
              height: SizeConfig.screenHeight! * 0.32,
              width: SizeConfig.screenWidth! * 0.6,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: chatMap['message'] != "" ? null : Alignment.center,
              child: chatMap['message'] != ""
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(
                        chatMap['message'],
                        fit: BoxFit.contain,
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
