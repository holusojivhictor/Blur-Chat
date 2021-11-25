import 'package:blur_chat/ui/group_chat_room/add_members_in_group.dart';
import 'package:blur_chat/ui/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({Key? key, required this.groupName, required this.groupId})
      : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      // ignore: avoid_print
      print(membersList);
      isLoading = false;
      setState(() {});
    });
  }

  bool checkAdmin() {
    bool isAdmin = false;

    membersList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title: const Text('Remove this member'),
                ),
              );
            });
      }
    }
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                    SizedBox(
                      height: size.height * 0.09,
                      width: size.width * 0.9,
                      child: Row(
                        children: [
                          Container(
                            height: size.height * 0.08,
                            width: size.width * 0.15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(Icons.group,
                                color: Colors.white, size: size.width * 0.05),
                          ),
                          SizedBox(width: size.width * 0.06),
                          Expanded(
                            child: SizedBox(
                              child: Text(
                                widget.groupName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Text(
                        "${membersList.length} members",
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    checkAdmin()
                        ? ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMembersInGroup(
                                  name: widget.groupName,
                                  groupChatId: widget.groupId,
                                  membersList: membersList,
                                ),
                              ),
                            ),
                            leading: const Icon(Icons.add),
                            title: Text(
                              "Add members",
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => showDialogBox(index),
                            leading: const Icon(Icons.account_circle),
                            title: Text(
                              membersList[index]['name'],
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(membersList[index]['email']),
                            trailing: Text(membersList[index]['isAdmin'] ? "Admin" : ""),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      onTap: onLeaveGroup,
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: Text(
                        "Leave group",
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
