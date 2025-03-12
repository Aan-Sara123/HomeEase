import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactAdminPage extends StatefulWidget {
  final String vendorId;

  const ContactAdminPage({super.key, required this.vendorId});

  @override
  State<ContactAdminPage> createState() => _ContactAdminPageState();
}

class _ContactAdminPageState extends State<ContactAdminPage> {
  final TextEditingController messageController = TextEditingController();
  String? replyingTo; // To track the message being replied to

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendMessage({required String sender, String? replyTo}) async {
    String message = messageController.text.trim();

    if (message.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.vendorId)
          .collection('messages')
          .add({
        'message': message,
        'sender': sender,
        'timestamp': DateTime.now(),
        'replyTo': replyTo, // Link reply to parent message
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sender == 'vendor'
              ? 'Message sent to admin successfully!'
              : 'Message sent to vendor successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear input and reply state
      messageController.clear();
      setState(() {
        replyingTo = null;
      });
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildReplyBadge(String message) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Replying to: $message",
              style: const TextStyle(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              setState(() {
                replyingTo = null;
              });
            },
          )
        ],
      ),
    );
  }

  Widget buildMessageItem(QueryDocumentSnapshot message) {
    bool isVendor = message['sender'] == 'vendor';
    String? replyTo = message['replyTo'];

    return Column(
      crossAxisAlignment:
          isVendor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isVendor ? Colors.purple.shade100 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (replyTo != null) // If it's a reply, show the referenced message
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.vendorId)
                      .collection('messages')
                      .doc(replyTo)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const SizedBox.shrink();
                    }

                    var parentMessage = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        parentMessage['message'],
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),

              // Message Text
              Text(
                message['message'],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        // Reply Button
        TextButton(
          onPressed: () {
            setState(() {
              replyingTo = message.id;
              messageController.text = ''; // Clear message box for new input
            });
          },
          child: const Text('Reply', style: TextStyle(color: Colors.blue)),
        ),

        // Display Replies
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.vendorId)
              .collection('messages')
              .where('replyTo', isEqualTo: message.id)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> replySnapshot) {
            if (!replySnapshot.hasData || replySnapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }

            var replies = replySnapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                children: replies.map((reply) {
                  return buildMessageItem(reply);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Admin'),
        backgroundColor: primaryPurple,
      ),
      body: Column(
        children: [
          // Display messages
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.vendorId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return buildMessageItem(message);
                  },
                );
              },
            ),
          ),

          // Message input and send buttons
          if (replyingTo != null)
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.vendorId)
                  .collection('messages')
                  .doc(replyingTo)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                var parentMessage = snapshot.data!;
                return buildReplyBadge(parentMessage['message']);
              },
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Write your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () =>
                      sendMessage(sender: 'vendor', replyTo: replyingTo),
                  icon: const Icon(Icons.send, color: primaryPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
