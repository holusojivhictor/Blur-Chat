import 'package:blur_chat/ui/group_chat_room/group_chat_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../size_config.dart';

class AddMembersToGroup extends StatefulWidget {
  const AddMembersToGroup({Key? key}) : super(key: key);

  @override
  _AddMembersToGroupState createState() => _AddMembersToGroupState();
}

class _AddMembersToGroupState extends State<AddMembersToGroup> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          "email": map['email'],
          "uid": map['uid'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;

        _search.clear();
      });
      // ignore: avoid_print
      print(userMap);
    });
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  void createGroup() async {

    setState(() {
      isLoading = true;
    });

    String groupId = const Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": membersList,
      "id": groupId,
    });

    for (int i = 0; i < membersList.length; i++) {
      String uid = membersList[i]['uid'];

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupName.text,
        "id": groupId,
      });
    }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message": "${_auth.currentUser!.displayName} created this group.",
      "type": "notify",
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GroupChatHomeScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Add members'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveMembers(index),
                    leading: Icon(
                      Icons.account_circle,
                      color: Theme.of(context).indicatorColor,
                      size: 40,
                    ),
                    title: Text(
                      membersList[index]['name'],
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      membersList[index]['email'],
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    trailing: Icon(
                      Icons.close,
                      color: Theme.of(context).indicatorColor,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: getPropScreenHeight(25)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.05,
                  width: SizeConfig.screenWidth! * 0.8,
                  child: TextField(
                    controller: _search,
                    cursorHeight: 16,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.grey, size: 18),
                      border: outlineInputBorder(),
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSearch,
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.search, size: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: getPropScreenHeight(10)),
            isLoading
                ? Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                : Container(),
            userMap != null
                ? ListTile(
                    onTap: onResultTap,
                    leading: Icon(
                      Icons.account_circle,
                      color: Theme.of(context).indicatorColor,
                      size: 40,
                    ),
                    title: Text(
                      userMap!['name'],
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      userMap!['email'],
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    trailing: Icon(
                      Icons.add,
                      color: Theme.of(context).indicatorColor,
                      size: 20,
                    ),
                  )
                : const SizedBox(),
            membersList.length >= 2
                ? Column(
                    children: [
                      SizedBox(height: getPropScreenHeight(30)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: SizeConfig.screenHeight! * 0.05,
                            width: SizeConfig.screenWidth! * 0.95,
                            child: TextField(
                              controller: _groupName,
                              decoration: InputDecoration(
                                hintText: "Enter group name",
                                hintStyle: const TextStyle(fontSize: 13),
                                border: outlineInputBorder(),
                                enabledBorder: outlineInputBorder(),
                                focusedBorder: outlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: getPropScreenHeight(25)),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                        onPressed: isLoading
                            ? () => Container(
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                )
                            : createGroup,
                        child: const Text('Create group'),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
  }
}
