import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/shared/components/components.dart';
class VariableController {
  final TextEditingController controller;
  final String variable;

  VariableController(this.controller, this.variable);
}
List<VariableController> createVariableControllers(int numberOfVariables) {
  List<VariableController> controllers = [];

  for (int i = 1; i <= numberOfVariables; i++){
    final controller = TextEditingController();
    controllers.add(VariableController(controller,'{{$i}}'));
  }

  return controllers;
}
class SendTemplet extends StatefulWidget {
  final templet;
  final Tamplates;
  const SendTemplet({Key key,this.templet,this.Tamplates}) : super(key: key);

  @override
  State<SendTemplet> createState() => _SendTempletState();
}

class _SendTempletState extends State<SendTemplet> {
  String variable;
  List<VariableController> controllers;





  var text = "";


 // List tampletvariables = [];

  //
  List tampletvariables = [];


  @override
  Widget build(BuildContext context){

//    tampletvariables =[];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor:Color(0xFF075e54),
        elevation: 0,
        title: Text('Send Template',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width:double.infinity,
              decoration:BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300], // Shadow color
                    offset: Offset(0, 0), // Offset of the shadow
                    blurRadius: 1, // Blur radius of the shadow
                    spreadRadius: 1, // Spread radius of the shadow
                  ),
                ],
              image:DecorationImage(image: AssetImage('assets/background.jpg'),fit: BoxFit.cover),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      color: Color(0xFFdcf8c6),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...widget.Tamplates['payload'].map((payload){
                              text = payload['text'];
                                payload['parameters'].forEach((paramter){
                                text = text.replaceFirst('{{${(payload['parameters'].indexOf(paramter) + 1).toString()}}}', paramter['text']);
                              });
                              return Column(
                                children: [
                                  if(payload['type']=='HEADER')
                                    payload['text']==null?SizedBox(height: 0,):Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 30,top: 15,bottom: 0),
                                      child: Text("${text}",style:TextStyle(color:Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold)),
                                    ),
                                  if(payload['type']=='BODY')
                                    payload['text']==null?SizedBox(height: 0,):Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 30,top: 10,bottom: 15),
                                      child: Text("${text}",style: TextStyle(color:Colors.black)),
                                    ),

                                  if(payload['type']=='FOOTER')
                                    payload['text']==null?SizedBox(height: 0,):Padding(padding:const EdgeInsets.only(left: 10,right: 30,top: 10,bottom: 15),
                                      child: Text("${text}",style: TextStyle(color:Color(0xff61677A))),
                                    )
                                ],
                              );
                            })
                          ]),
                    ),
                  ),
                ],
              ),
           ),
           
           ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount:widget.Tamplates['payload'].length,
              itemBuilder: (context,index){
                final List<VariableController> controllers = createVariableControllers(widget.Tamplates['payload'][index]['parameters'].length);
                String capitalized = widget.Tamplates['payload'][index]['type'][0].toUpperCase() + widget.Tamplates['payload'][index]['type'].substring(1).toLowerCase();
                return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[

                 if(widget.Tamplates['payload'][index]['parameters'].length>0)
                 Padding(
                   padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 15),
                   child: Text('${capitalized}',style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.w500,

                   )),
                 ),
                  for (var i = 0; i < controllers.length ;i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20,top:10,bottom:5),
                      child: TextField(
                        maxLines:widget.Tamplates['payload'][index]['type']=='BODY'?3:1,
                        onChanged: (value) {
                            setState(() {
                              widget.Tamplates['payload'][index]['parameters'][i]['text'] = value;
                            });
                        },
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color:Color(0xff9BABB8)),
                          labelText: 'Entre your content for ${widget.Tamplates['payload'][index]['type'].toLowerCase()}',
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
                                ))
                        ),
                      ),
                    ),
                ],
            );
          }),

           height(50),
           Padding(
             padding: const EdgeInsets.only(left: 20,right: 20),
             child: Container(
               height: 50,
               width: double.infinity,
               decoration: BoxDecoration(
                 color: Colors.red,
                 borderRadius: BorderRadius.circular(5)
               ),
               child: TextButton(onPressed: (){}, child:Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   Text('Send',style: TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                     fontSize: 17
                   ),),
                   width(3),
                   Padding(
                     padding: const EdgeInsets.only(top: 3),
                     child: Transform.rotate(
                         angle: -0.5,
                         alignment: Alignment.topLeft,
                         child: Icon(Icons.send,color: Colors.white,)),
                   )
                 ],
               ))),
           )
          ],
        ),
      ),
    );
  }
}
