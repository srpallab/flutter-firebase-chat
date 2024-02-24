import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaan_pakhi_chat/widgets/chat_bubble.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("messages")
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (BuildContext ctx,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No Data Found"));
              }
              final List<QueryDocumentSnapshot<Map>> loadedMsg =
                  snapshot.data!.docs;

              return ListView.builder(
                itemCount: loadedMsg.length,
                reverse: true,
                itemBuilder: (BuildContext _, index) {
                  final Map chatMsg = loadedMsg[index].data();
                  final Map? nextChatMsg = index + 1 < loadedMsg.length
                      ? loadedMsg[index + 1].data()
                      : null;
                  final String currentUserId = chatMsg['user_id'];
                  final dynamic nextUserId =
                      nextChatMsg != null ? nextChatMsg['user_id'] : null;
                  final nextUserIsSame = nextUserId == currentUserId;
                  if (nextUserIsSame) {
                    return ChatBubble.next(
                      message: chatMsg['text'],
                      isMe: user.uid == currentUserId,
                    );
                  } else {
                    return ChatBubble.first(
                      userImage: chatMsg['image_url'],
                      username: chatMsg['username'],
                      message: chatMsg['text'],
                      isMe: user.uid == currentUserId,
                    );
                  }
                },
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text("Something Went Wrong!"));
            }
            return const Center(child: Text("Something Went Wrong!"));
        }
      },
    );
  }
}
