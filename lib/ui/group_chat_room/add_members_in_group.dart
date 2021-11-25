import 'package:blur_chat/constants.dart';
import 'package:blur_chat/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMembersInGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersInGroup(
      {Key? key,
      required this.name,
      required this.groupChatId,
      required this.membersList})
      : super(key: key);

  @override
  _AddMembersInGroupState createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    membersList = widget.membersList;
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
      });
      // ignore: avoid_print
      print(userMap);
    });
  }

  void onAddMembers() async {
    membersList.add(userMap);

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(userMap!['uid'])
        .collection('groups')
        .doc(widget.groupChatId)
        .set({
      "name": widget.name,
      "id": widget.groupChatId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add members'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
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
                    child: const Icon(Icons.search, size: 20, color: Colors.grey),
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
                    onTap: onAddMembers,
                    leading: const Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
