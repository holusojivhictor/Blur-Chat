import 'package:blur_chat/constants.dart';
import 'package:blur_chat/data/methods.dart';
import 'package:blur_chat/size_config.dart';
import 'package:blur_chat/ui/singles_chat_room/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'group_chat_room/group_chat_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  bool isUserListLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
    displayUserList();
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Online
      setStatus("Online");
    } else {
      // Offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {

      return "$user1$user2";
    } else if (user1[0].toLowerCase().codeUnits[0] <
        user2[0].toLowerCase().codeUnits[0]) {

      return "$user2$user1";
    } else {

      return "${user1[0]}${user2[0]}";
    }
  }

  void displayUserList() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isUserListLoading = true;
    });

    await _firestore.collection('users').get().then((value) {
      setState(() {
        isUserListLoading = false;
      });
    });
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Blur Chat"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => logOut(context), icon: const Icon(Icons.logout, size: 20)),
        ],
      ),
      body: isLoading
          ? const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  SizedBox(height: getPropScreenHeight(20)),
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
                  SizedBox(height: SizeConfig.screenHeight! * 0.03),
                  userMap != null
                      ? ListTile(
                          onTap: () {
                            String roomId = chatRoomId(
                                _auth.currentUser!.displayName!,
                                userMap!['name']);

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ChatRoom(
                                      chatRoomId: roomId,
                                      userMap: userMap!,
                                    )));
                          },
                          leading: Icon(Icons.account_circle,
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
                          trailing: Icon(Icons.chat,
                            color: Theme.of(context).indicatorColor,
                            size: 20,
                          ),
                        )
                      : Container(),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userListMap = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                            return userTile(userListMap, context);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GroupChatHomeScreen()));
        },
      ),
    );
  }

  Widget userTile(Map<String, dynamic> userListMap, BuildContext context) {
    return Builder(builder: (_) {
      return ListTile(
        onTap: () {
          String roomId = chatRoomId(
              _auth.currentUser!.displayName!,
              userListMap['name']);

          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatRoom(
                chatRoomId: roomId,
                userMap: userListMap,
              )),
          );
        },
        leading: Icon(Icons.account_circle,
            color: Theme.of(context).indicatorColor,
            size: 40),
        title: Text(
          userListMap['name'],
          style: Theme.of(context).textTheme.headline4,
        ),
        subtitle: Text(
          userListMap['email'],
          style: Theme.of(context).textTheme.bodyText2,
        ),
        trailing: Icon(Icons.chat,
            color: Theme.of(context).indicatorColor,
            size: 20),
      );
    });
  }
}
