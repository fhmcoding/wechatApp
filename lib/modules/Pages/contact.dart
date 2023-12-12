
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/remote/cachehelper.dart';
import 'package:wechat/modules/Pages/users.dart';
import '../../shared/components/components.dart';

import 'accounts.dart';
import 'chatScreen.dart';

class Contact extends StatefulWidget {
  final user;
  final name;
  const Contact({ Key key,this.user, this.name}) : super(key: key);

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  bool isSearch = false;
  List usersFilter = [];
  List list = [];
  var lastmessage = '';
  var status;
  var time;
   String access_token = Cachehelper.getData(key:"token");
   String role = Cachehelper.getData(key:"role");
   bool isloading = true;
   List accounts = [];
   String sender = '';

   var Message;

   Future getContacts() async {
     isloading = false;
     final response = await http.get(
       Uri.parse('https://wechat.canariapp.com/api/v1/contacts?account=${widget.user['_id']}'),
       headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
     ).then((value){
       if(value.statusCode==200){
         var responsebody = jsonDecode(value.body);
         print('--------------------------------------');
         print(responsebody);
         print('--------------------------------------');
         accounts = responsebody;
         accounts.sort((a, b) => DateTime.parse(b['lastMessage']['timestamp'])
             .compareTo(DateTime.parse(a['lastMessage']['timestamp'])));
         list = usersFilter = accounts;
         setState(() {
           isloading = true;
         });
       }else{
         setState(() {
           print('error');
           isloading = true;
         });
       }

     }).onError((error, stackTrace){
       print(error);
     });
     return response;
   }


  void filterUsers(value){
    setState(() {
      usersFilter = list.where((element) => element['contact']['name'].toLowerCase().contains(value.toLowerCase()) || element['contact']['phone_number'].toLowerCase().contains(value.toLowerCase())).toList();
    });
  }


  // IO.Socket socket;
  // void ChangeStatusListener(){
  //   socket.on("message-status-changed", (data) {
  //     print('socket data : ${data['receiver']}');
  //     String receiver = data['receiver'];
  //     String status = data['status'];
  //     for (var contact in accounts) {
  //       if (contact['_id'] == receiver){
  //         if (mounted) {
  //           setState(() {
  //             contact['status'] = status;
  //             print(status);
  //           });
  //         }
  //         break;
  //       }
  //     }
  //   });
  // }
  // void connectToSocket(){
  //   socket = io('https://wechat.canariapp.com',
  //       OptionBuilder()
  //           .setTransports(['websocket']) // for Flutter or Dart VM
  //           .disableAutoConnect()  // disable auto-connection
  //           .setExtraHeaders({'token':'${access_token}'}) // optional
  //           .build()
  //   );
  //   socket.connect();
  //   ChangeStatusListener();
  //   socket.onConnect((data){
  //    print('--------------------------------------------');
  //    print('connected');
  //    print('--------------------------------------------');
  //   });
  // }

  @override
  void initState() {
    getContacts();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
     print(Message);
    return Scaffold(
       floatingActionButton: CircleAvatar(
         maxRadius: 30,
         backgroundColor:Color(0xFF075e54),
         child: IconButton(onPressed: (){}, icon: Icon(Icons.message,color: Colors.white,)),
       ),
        backgroundColor:Colors.white,
        appBar:AppBar(
          toolbarHeight: 65,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child:isSearch == false?
                GestureDetector(
                    onTap: (){
                      setState(() {
                        isSearch = true;
                      });
                    },
                    child:Icon(Icons.search,color: Colors.white,)):GestureDetector(
                      onTap: (){
                        setState(() {
                          isSearch = false;
                          usersFilter = list;
                        });
                      },
                     child:isSearch == false? Icon(Icons.search,color: Colors.white,):Icon(Icons.close,color: Colors.white,)),
              ),

              isSearch == false?role=='admin'?PopupMenuButton<String>(
                onSelected:(value){
                  if(value == 'Accounts'){
                    print('Accounts');
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Accounts()));
                  }else if(value == 'Users'){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Users()));
                  }else if(value == 'Logout'){
                    print('Logout');
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'Accounts',
                      child: Text('Accounts'),
                    ),
                    PopupMenuItem<String>(
                      value: 'Users',
                      child: Text('Users'),
                    ),
                    PopupMenuItem<String>(
                      value: 'Logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
              ):SizedBox(height: 0,):GestureDetector(
                onTap: (){},
                child: Icon(Icons.more_vert),
              ),
            ],
            elevation:0,
            backgroundColor:Color(0xFF075e54),
            title:isSearch == false?Text("WeChats",style: TextStyle(color: Colors.white),):TextField(
              decoration: InputDecoration(
                  hintText: 'Search',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.white,
                )
              ),
              autofocus:true,
              style: TextStyle(color: Colors.white),
              onChanged: (value){
                filterUsers(value);
              },
            )
    ),
        body:isloading?SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              usersFilter.length>0?ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: usersFilter.length,
                  shrinkWrap: true,
                  itemBuilder: (context,index){
                    var account = usersFilter[index];
                    lastmessage = account['lastMessage']['message']['body'];
                    status = account['lastMessage']['status'];
                    time = account['lastMessage']['timestamp'];
                    // if(Message!=null){
                    //   if(account['_id']==Message['receiver']){
                    //     print('-----------------------------------');
                    //
                    //     account['lastMessage']['message']['body'] = Message['message']['body'];
                    //     status = Message['status'];
                    //     time = Message['timestamp'];
                    //     print("from message ${usersFilter[index]}");
                    //     print('-----------------------------------');
                    //   }else{
                    //     // lastmessage = account['lastMessage']['message']['body'];
                    //     status = account['lastMessage']['status'];
                    //     time = account['lastMessage']['timestamp'];
                    //   }
                    // }else{
                    //    lastmessage = account['lastMessage']['message']['body'];
                    //   status = account['lastMessage']['status'];
                    //   time = account['lastMessage']['timestamp'];
                    //
                    //   print('last message ${lastmessage}');
                    // }



                    return GestureDetector(
                      onTap: ()async{
                        var message =  await Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(
                            account:account,
                            sender:widget.user['_id'],
                            user:widget.user,
                            receiver_id:accounts[index]['_id'],
                            name:widget.name
                        )));
                        setState(() {
                          account = message;
                          print("from messafe ${message}");
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              child: Row(
                                children:[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child:Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50),
                                              color: Colors.grey
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(50),
                                            child:account['contact']['image']!=null?
                                            Image.network('${account['contact']['image']}',height: 60,width:60,):
                                            Image.asset('assets/default.png',height: 60,width:60,),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Text("${account['contact']['name']}",style:TextStyle(color: Colors.black,fontSize: 16) ,),
                                        ),
                                        SizedBox(
                                            height: 20,
                                            child:Row(
                                              children: [
                                                Column(
                                                 children: [
                                                   widget.user['_id']==account['lastMessage']['receiver']?buildStatus(status):SizedBox(height: 0,),
                                                   // Message['sender']==account['_id']?SizedBox(height: 0,):buildStatus(status),
                                                 ],
                                               ),
                                                SizedBox(width: 3,),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if(account['lastMessage']['message_type']=='text')
                                                      Expanded(child: Text("${account['lastMessage']['message']['body']}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11, fontWeight: account['unreadCount']>0?FontWeight.bold:FontWeight.w500,color: account['unreadCount']>0?Colors.black:Color(0xff667781)),)),
                                                      if(account['lastMessage']['message_type']=='template')
                                                      Expanded(child: Text("${account['lastMessage']['message']['body']}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11, fontWeight: account['unreadCount']>0?FontWeight.bold:FontWeight.w500,color: account['unreadCount']>0?Colors.black:Color(0xff667781)),)),
                                                      if(account['lastMessage']['message_type']=='image')
                                                        Row(
                                                          children: [
                                                            Icon(Icons.camera_alt,size: 16,color: Colors.grey[400]),
                                                            width(4),
                                                            Text('Photo',style: TextStyle(color:Colors.black),),
                                                          ],),
                                                      if(account['lastMessage']['message_type']=='audio')
                                                        Row(
                                                          children: [
                                                            Icon(Icons.audiotrack_rounded,size: 16,color: Colors.grey[400]),
                                                            width(4),
                                                            Text('Audio',style: TextStyle(color:Colors.black),),
                                                          ],)

                                                      // if(account['message_type']=='text')
                                                      // Expanded(child: Text("${account['lastMessage']['message']}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11, fontWeight: account['unreadCount']>0?FontWeight.bold:FontWeight.w500,color: account['unreadCount']>0?Colors.black:Color(0xff667781)),)),

                                                      // Expanded(child: Text("${Message['sender']==account['_id']?Message['message']['body']:account['lastMessage']['message']['body']}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11, fontWeight: account['unreadCount']>0?FontWeight.bold:FontWeight.w500,color: account['unreadCount']>0?Colors.black:Color(0xff667781)),)),
                                                      // if(Message['message_type']=='text')
                                                      // Expanded(child: Text("${account['lastMessage']['message']['body']}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11, fontWeight: account['unreadCount']>0?FontWeight.bold:FontWeight.w500,color: account['unreadCount']>0?Colors.black:Color(0xff667781)),)),
                                                      // if(Message['message_type']=='image')
                                                      // Message['sender']==account['_id']?Row(
                                                      //       children: [
                                                      //         Icon(Icons.camera_alt,size: 16,color: Colors.grey[400]),
                                                      //         width(4),
                                                      //         Text('Photo',style: TextStyle(color:Colors.black),),
                                                      //       ],):Text('${account['lastMessage']['message']['body']}')
                                                      ],
                                                  ),
                                                )
                                                // if(Message['message_type']=='image')
                                                //   Message['sender']==account['_id']?Row(
                                                //     children: [
                                                //       Icon(Icons.camera_alt,size: 16,color: Colors.grey[400]),
                                                //       width(4),
                                                //       Text('Photo',style: TextStyle(color:Colors.black),),
                                                //     ],
                                                //   ):Text('${account['lastMessage']['message']['body']}')
                                              ],
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("${DateTime.parse(time).hour}:${DateTime.parse(time).minute}",style: TextStyle(color: Color(0xff667781),fontSize: 11),),
                                        SizedBox(height: 5,),
                                        account['unreadCount']==0?SizedBox(height: 0):CircleAvatar(minRadius: 9,child: Text("${account['unreadCount']}",style: TextStyle(color: Colors.white,fontSize: 11),),backgroundColor: Color(0xFF25d366),)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )

                          ],
                        ),
                      ),
                    );
                  }
              ):
              ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: accounts.length,
                  shrinkWrap: true,
                  itemBuilder: (context,index){
                    var account = accounts[index];
                    lastmessage = account['lastMessage']['message']['body'];
                    status = account['lastMessage']['status'];
                    time = account['lastMessage']['timestamp'];
                    // print('from account ${accounts[index]}');
                    // if(Message!=null){
                    //   if(account['_id']==Message['receiver']){
                    //     print('-----------------------------------');
                    //     lastmessage = Message['message']['body'];
                    //     status = Message['status'];
                    //     time = Message['timestamp'];
                    //     print("from message ${Message}");
                    //     print('-----------------------------------');
                    //   }else{
                    //     lastmessage = account['lastMessage']['message']['body'];
                    //     status = account['lastMessage']['status'];
                    //     time = account['lastMessage']['timestamp'];
                    //   }
                    // }else{
                    //   lastmessage = account['lastMessage']['message']['body'];
                    //   status = account['lastMessage']['status'];
                    //   time = account['lastMessage']['timestamp'];
                    // }



                    return  GestureDetector(
                      onTap: ()async{
                     var message =  await Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(
                          account:account,
                          sender:widget.user['_id'],
                          user:widget.user,
                          receiver_id:accounts[index]['_id'],
                          name:widget.name
                        )));
                     setState(() {
                       account = message;
                       print("${message}");
                     });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: buildUsers(context,account,lastmessage,Message,status,time,sender:widget.user['_id']),
                      ),
                    );
                  }
              )
            ],
          )
        ):Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: CircularProgressIndicator(color: Color(0xFF075e54)))
          ],
        ),
    );
  }
}


