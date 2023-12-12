import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/remote/cachehelper.dart';

import '../../shared/components/components.dart';

class CreateAccount extends StatefulWidget {
  List accounts;
   CreateAccount({Key key,this.accounts}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool isloading = true;
  String access_token = Cachehelper.getData(key:"token");
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController idphonecontroller = TextEditingController();
  Future CreateAccount() async {
    setState(() {
      isloading = false;
    });
    final response = await http.post(
      Uri.parse('https://wechat.canariapp.com/api/v1/accounts'),
      body: jsonEncode(
          {
            "name":"${namecontroller.text}",
            "phone_number": "${phonecontroller.text}",
            "phone_number_id": "103628725984485"
          }
      ),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);
        print('--------------------------------------');
        print(responsebody);
        print('--------------------------------------');
        setState(() {
          isloading = true;
          widget.accounts.add(responsebody);
          Navigator.pop(context,widget.accounts);
        });
      }else{
        var responsebody = jsonDecode(value.body);
        setState(() {
          print('${responsebody}');
          isloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation:0,
        backgroundColor:Color(0xFF075e54),
        title: Text('Create Account'),
      ),
      body:Directionality(
        textDirection: TextDirection.ltr,
        child: Form(
          key: fromkey,
          child: Padding(
            padding: const EdgeInsets.only(top: 25,left:15,right:15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text('Account Name',style: TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.w500,
                ),),
                height(15),
                DefaultTextfiled(
                    maxLines: 1,
                    label: "Account Name",
                    controller: namecontroller,
                    hintText: 'Account Name',
                    keyboardType: TextInputType.text,
                ),
                height(20),
                Text('Account Phone',style: TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.w500,
                ),),
                height(15),
                DefaultTextfiled(
                    maxLines: 1,
                    label: "Account Phone",
                    controller: phonecontroller,
                    hintText: 'Account Phone',
                    keyboardType: TextInputType.text,
                ),
                height(20),
                Text('Account PhoneId',style: TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.w500,
                ),),
                height(15),
                DefaultTextfiled(
                  maxLines: 1,
                  label: "Account PhoneId",
                  controller: idphonecontroller,
                  hintText: 'Account PhoneId',
                  keyboardType: TextInputType.text,
                ),
                height(25),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 0,
                      right: 0
                  ),
                  child: GestureDetector(
                    onTap: (){
                      if (fromkey.currentState.validate()) {
                        fromkey.currentState.save();
                        CreateAccount();
                      }
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:BorderRadius.circular(5),
                      ),
                      child:Center(child:isloading? Text('Create Account',style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17
                      ),):CircularProgressIndicator(color: Colors.white,)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
