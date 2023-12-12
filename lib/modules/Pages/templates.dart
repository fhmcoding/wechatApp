import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wechat/modules/Pages/send_templet.dart';
import 'package:wechat/shared/components/components.dart';
import 'dart:convert';
import '../../shared/remote/cachehelper.dart';
class Templates extends StatefulWidget {
  const Templates({Key key}) : super(key: key);

  @override
  State<Templates> createState() => _TemplatesState();
}

class _TemplatesState extends State<Templates> {
  String access_token = Cachehelper.getData(key:"token");
  List Templates = [];
  bool isloading = true;
  Future getTemplates() async {
   setState(() {
     isloading = false;
   });
    final response = await http.get(
      Uri.parse('https://wechat.canariapp.com/api/v1/templates'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);
        print('--------------------------------------');

         Templates = responsebody;
        print('templates :${responsebody}');
        print('--------------------------------------');

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

@override
  void initState() {
  getTemplates();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor:Color(0xFF075e54),
        elevation: 0,
        title: Text('Templates',style: TextStyle(color: Colors.white),),
      ),
      body:
      Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/background.jpg'),fit: BoxFit.cover)
        ),
        child:isloading?SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
               ListView.builder(
                 physics: NeverScrollableScrollPhysics(),
                 shrinkWrap: true,
                   itemCount:Templates.length,
                   itemBuilder: (context,index){
                 return Align(
                     alignment: AlignmentDirectional.topStart,
                     child:ConstrainedBox(
                       constraints:BoxConstraints(
                           maxWidth: MediaQuery.of(context).size.width - 60
                       ),
                       child: GestureDetector(
                         onTap: (){
                         Navigator.push(context, MaterialPageRoute(builder: (builder)=>SendTemplet(templet:Templates[index]['components'],Tamplates:Templates[index],)));
                         },
                         child: Card(
                           color: Color(0xFFdcf8c6),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 ...Templates[index]['components'].map((component){
                                   return Column(
                                     children: [
                                       if(component['type']=='HEADER')
                                         component['text']==null?SizedBox(height: 0,): Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 30,top: 15,bottom: 0),
                                        child: Text("${component['text']}",style: TextStyle(color:Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold)),
                                       ),
                                       if(component['type']=='BODY')
                                         component['text']==null?SizedBox(height: 0,): Padding(
                                         padding: const EdgeInsets.only(left: 10,right: 30,top: 10,bottom: 15),
                                         child: Text("${component['text']}",style: TextStyle(color:Colors.black)),
                                       ),

                                       if(component['type']=='FOOTER')
                                         component['text']==null?SizedBox(height: 0,): Padding(
                                           padding: const EdgeInsets.only(left: 10,right: 30,top: 10,bottom: 15),
                                           child: Text("${component['text']}",style: TextStyle(color:Color(0xff61677A))),
                                         )
                                     ],
                                   );
                                 })
                               ]),
                         ),
                       ),
                     )
                 );
               })
              ],
            ),
          ),
        ):Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: CircularProgressIndicator(color: Color(0xFF075e54)))
          ],
        ),
      )
    );
  }
}
