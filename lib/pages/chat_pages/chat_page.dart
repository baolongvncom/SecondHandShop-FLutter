import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_turtorial/components/chat_bubble.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/chat_services/chat_service.dart';
import 'package:firebase_auth_turtorial/pages/chat_pages/utils.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  const ChatPage({
    super.key,
    required this.receiverUserEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _authService = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if there is anything to send
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(
          _messageController.text, widget.receiverUserEmail);
      // clear message controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: royalBlue,
      appBar: AppBar(
        title: Text(widget.receiverUserEmail.split('@')[0]),
        // make app bar transparent
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(children: [
        // build messages
        Expanded(
            child: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: _buildMessageList(),
        )),
        // user input
        _buildMessageInput(),
      ]),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            _authService.currentUser?.email ?? '', widget.receiverUserEmail),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: const BoxDecoration(
                  color: peachColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: const Center(
                child: Text('Loading...'),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
                color: peachColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: ListView(
              // reverse the list so that the latest message is at the bottom
              reverse: true,

              children: snapshot.data!.docs
                  .map((document) => _buildMessageItem(document))
                  .toList(),
            ),
          );
        });
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // align message to the right if it is sent by current user, otherwise align to the left
    var alignment = data['senderUID'] == _authService.currentUser?.uid
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment:
                data['senderUID'] == _authService.currentUser?.uid
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ChatBubble(message: data['message']),
              Text(
                data['time'].toDate().toString().substring(0, 16),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ]),
      ),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: peachColor,
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40), color: Colors.grey[200]),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your message',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            CircleAvatar(
              backgroundColor: royalBlue,
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send, size: 25, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
