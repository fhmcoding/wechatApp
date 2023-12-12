import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wechat/modules/Login/login.dart';
import 'package:wechat/shared/remote/cachehelper.dart';

import 'Layout/HomeLayout/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Cachehelper.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}


//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   TextEditingController _messageController = TextEditingController();
//   List<String> _messages = [];
//
//    IO.Socket socket;
//
//   @override
//   void initState() {
//     super.initState();
//     socket = IO.io('YOUR_SERVER_URL', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//     socket.connect();
//
//     socket.on('connect', (_) {
//       print('Connected');
//     });
//
//     socket.on('message', (data) {
//       setState(() {
//         _messages.add(data);
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     socket.dispose();
//     super.dispose();
//   }
//
//   void _sendMessage(String message) {
//     socket.emit('message', message);
//     print('${message}');
//     _messages.add(message);
//     setState(() {
//
//     });
//     _messageController.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Chat App'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_messages[index]),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(labelText: 'Type your message...'),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () => _sendMessage(_messageController.text),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

