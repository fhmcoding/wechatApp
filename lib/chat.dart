import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final List<String> messages = [
    "first message",
    "How are you?",
    "I'm good. How about you?",
    "I'm great, thanks!",
    "Hello!",
    "How are you?",
    "I'm good. How about you?",
    "I'm great, thanks!",
    "Hello!",
    "How are you?",
    "I'm good. How about you?",
    "I'm great, thanks!","Hello!",
    "How are you?",
    "I'm good. How about you?",
    "I'm great, thanks!","Hello!",
    "How are you?",
    "I'm good. How about you?",
    "I'm great, thanks!","Hello!",
    "How are you?",
    "I'm good. How about you?",
    "I'm great, thanks!",
    "How are you?",
    "I'm good. How about you?",
    "I'm great, thanks!","Hello!",
    "How are you?",
    "I'm good. How about you?",
    "last message",
    // Add more messages here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: ListView.builder(
        reverse: true, // Display messages in reverse order
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          final message = messages[index];
          return ListTile(
            title: Text(message),
          );
        },
      ),
    );
  }
}


