import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'messages.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgCtl = TextEditingController();
  Future<void> sendMessage() async {
    if (msgCtl.text.trim().isNotEmpty) {
      final User user = FirebaseAuth.instance.currentUser!;
      final DocumentSnapshot<Map<String, dynamic>> userData =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();
      await FirebaseFirestore.instance.collection('messages').add(
        {
          'text': msgCtl.text,
          'created_at': Timestamp.now(),
          'user_id': user.uid,
          'username': userData.data()!["username"],
          'image_url': userData.data()!["image_url"],
        },
      );
    }

    msgCtl.clear();
  }

  Future<void> setupPushNotifications() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // fcm.subscribeToTopic("chat");
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }

  @override
  void dispose() {
    msgCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(child: MessagesScreen()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: msgCtl,
                    maxLines: null,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      hintText: "Write a message and click send",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
