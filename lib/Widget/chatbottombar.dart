import 'package:flutter/material.dart';

class ChatBottomBar extends StatelessWidget {
  const ChatBottomBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background.jpg'),fit: BoxFit.cover)
      ),
     height:65,
     child:Padding(
       padding: const EdgeInsets.all(5.0),
       child: Row(
          children:[
            Container(
              width: MediaQuery.of(context).size.width-70,
              child: Card(
                margin: EdgeInsets.only(left: 2,right: 2,bottom: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
                ),
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIconColor: Colors.grey,
                    suffixIconColor:Colors.grey,
                    enabledBorder: InputBorder.none,
                    hintText: 'Type a message',
                    contentPadding: EdgeInsets.only(left: 20),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            splashRadius: 25,
                            onPressed: (){}, icon: Icon(Icons.attachment_rounded)),
                        IconButton(
                            splashRadius: 25,
                            onPressed: (){}, icon: Icon(Icons.camera_alt_outlined))
                      ],
                    )

                  ),


                ),
              ),
            ),

           Card(
             elevation: 5,
             color:Color(0xFF00887A),
             shadowColor: Colors.grey[300],
             shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(30)
             ),
             child:IconButton(
                 splashRadius: 25,
                 onPressed: (){

                 }, icon:Icon(Icons.send,color: Colors.white,)) ,
           )
          ],
        ),
     ),
    );
  }
}
