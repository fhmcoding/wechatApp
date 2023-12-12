import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as ui;

import '../modules/Pages/contact.dart';
import '../shared/components/components.dart';
class Chats extends StatefulWidget {
   bool sentByMe;
   final message;
   final user;
   final index;
   final messages;
   final send;
   final received;
   final status;
   final time;
   final isSend;
   Chats({Key key,this.sentByMe,this.message,this.user, this.index, this.messages, this.send,this.received, this.status,this.time,this.isSend}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {

    @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.sentByMe?
         Align(
           alignment:AlignmentDirectional.topEnd,
           child: ConstrainedBox(
             constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 60
             ),
             child: Card(
               color: Color(0xFFdcf8c6),
               child:Stack(
                 children:[
                   if(widget.messages[widget.index]['message_type']=='text')
                   Padding(padding: EdgeInsets.only(left: 10,right: 60,top: 6,bottom: 0),
                     child:  Text("${widget.user}",style: TextStyle(color:Colors.red,fontSize: 11.0,fontWeight: FontWeight.w500)),
                   ),
                   if(widget.messages[widget.index]['message_type']=='text')
                     Padding(padding: EdgeInsets.only(left: 10,right: 60,top: 20,bottom: 20),
                       child: Text('${widget.message}',style:TextStyle(
                           fontSize: 16
                       )),
                     ),
                   if(widget.messages[widget.index]['message_type']=='text')
                    Positioned(
                       bottom: 1,
                       right: 10,
                       child: Row(
                         children: [
                           Text('${DateTime.parse(widget.time).hour}:${DateTime.parse(widget.time).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),),
                           SizedBox(width: 5,),
                           buildStatus(widget.status)
                         ],
                       )),
                   if(widget.messages[widget.index]['message_type']=='image')
                     Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 20),
                         child:Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Image.network('${widget.messages[widget.index]['message']['link']}'),
                           ],
                         )
                     ),
                   if(widget.messages[widget.index]['message_type']=='template')
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Padding(padding: EdgeInsets.only(left: 0,right: 60,top: 6,bottom: 5),
                             child:  Text("${widget.user}",style: TextStyle(color:Colors.red,fontSize: 11.0,fontWeight: FontWeight.w500)),
                           ),
                         Text("${widget.messages[widget.index]['message']['header']}",style: TextStyle(
                           fontWeight: FontWeight.bold,
                         )),

                        Text('${widget.message}',style:TextStyle(
                         fontSize: 16
                          )),
                           Text("${widget.messages[widget.index]['message']['footer']}",style: TextStyle(
                                       fontWeight: FontWeight.w400,
                                       color: Colors.grey[600]
                                   )),
                           if(widget.messages[widget.index]['message_type']=='template')
                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               Text('${DateTime.parse(widget.time).hour}:${DateTime.parse(widget.time).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),),
                               SizedBox(width: 5,),
                               buildStatus(widget.status)
                             ],
                           )
                          ],
                       ),
                     ),
                 ],
               ),
             ),
           ),
         )
        : ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45
          ),
          child: Card(
                color: Color(0xFFFFFFFF),
                elevation: 1,
                child:Stack(
                  children:[
                    if(widget.messages[widget.index]['message_type']=='text')
                    Padding(padding: EdgeInsets.only(left: 10,right: 60,top: 10,bottom: 20),
                     child: Text('${widget.message}',style: TextStyle(
                      fontSize: 16
                    )),
                    ),
                    if(widget.messages[widget.index]['message_type']=='image')
                    Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 20),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network('${widget.messages[widget.index]['message']['url']}'),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('This is my card here you can show it to anyone you want'),
                          ),
                        ],
                      )
                    ),
                    Positioned(
                     bottom: 4,
                     right: 10,
                        child: Text('${DateTime.parse(widget.time).hour}:${DateTime.parse(widget.time).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),))
                  ],
                ),
              ),
        ),
      ]
    );
  }
}
