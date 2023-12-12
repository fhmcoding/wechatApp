import 'package:flutter/material.dart';
Widget buildStatus(status){
  if(status==null){
    return Icon(Icons.access_time,size: 18,color: Colors.grey);
  }
  if(status=="pending"){
    return Icon(Icons.access_time,size: 18,color: Colors.grey);
  }
  if(status=="sent"){
    return Icon(Icons.check,size: 18,color: Colors.grey);
  }
  if(status=="delivered"){
    return Icon(Icons.done_all,color: Colors.grey,size: 18,);
  }
  if(status=="read"){
    return Icon(Icons.done_all,color: Colors.blue,size: 18,);
  }
  if(status=="failed"){
    return Icon(Icons.info,color: Colors.red,size: 18,);
  }
}

Widget buildUsers(context,account,lastmessage,message,status,time,{sender}){
  return
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
                      account['lastMessage']['receiver'] == sender?SizedBox(height: 0,):buildStatus(status),
                      SizedBox(width: 3,),
                      Expanded(child: Text("${lastmessage}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 11, fontWeight: account['unreadCount']>0?FontWeight.bold:FontWeight.w500,color: account['unreadCount']>0?Colors.black:Color(0xff667781)),)),
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
              account['unreadCount']==0?SizedBox(height: 0):CircleAvatar(minRadius:9,child: Text("${account['unreadCount']}",style: TextStyle(color: Colors.white,fontSize: 11),),backgroundColor: Color(0xFF25d366),)
            ],
          ),
        )
      ],
    ),
  );
}



void printFullText(String text) {
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

Widget DefaultTextfiled({String hintText,String label,TextEditingController controller ,TextInputType keyboardType,int maxLines}){
  return TextFormField(
    maxLines: maxLines,
    keyboardType:keyboardType,
    controller:controller,
    style: TextStyle(color: Colors.black),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return '${hintText} لا يجب أن تكون فارغة ';
      }
      return null;
    },
    decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xff9BABB8),
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xff9BABB8),
            )),
        hintText: hintText,
        label: Text(label),
        hintStyle: TextStyle(
          color: Color(0xFF7B919D),
        )),
  );
}

Widget height(
    double height,
    ) {
  return SizedBox(
    height: height,
  );
}

Widget width(
    double width,
    ) {
  return SizedBox(
    width: width,
  );
}