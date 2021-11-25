import 'package:blur_chat/size_config.dart';
import 'package:blur_chat/ui/group_chat_room/group_chat_room.dart';
import 'package:blur_chat/ui/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_members.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 22),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Groups'),
        centerTitle: true,
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: getPropScreenHeight(3)),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GroupChatRoom(
                            groupName: groupList[index]['name'],
                            groupChatId: groupList[index]['id'],
                          ),
                        ),
                      );
                    },
                    leading: Icon(Icons.account_circle,
                      color: Theme.of(context).indicatorColor,
                      size: 40,
                    ),
                    title: Text(
                      groupList[index]['name'],
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    trailing: Icon(Icons.chat,
                      color: Theme.of(context).indicatorColor,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.create),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddMembersToGroup()),
          );
        },
        tooltip: "Create Group",
      ),
    );
  }
}
