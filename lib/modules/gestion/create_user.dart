import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/remote/cachehelper.dart';
import 'package:flutter/material.dart';
import '../../shared/components/components.dart';

class CreateUser extends StatefulWidget {
  List users;
   CreateUser({Key key, this.users}) : super(key: key);

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  @override
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  bool isloading = true;
  String access_token = Cachehelper.getData(key:"token");
  TextEditingController namecontroller = TextEditingController();
  TextEditingController userNamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  Future CreateUser() async {
   setState(() {
     isloading = false;
   });
    final response = await http.post(
      Uri.parse('https://wechat.canariapp.com/api/v1/users'),
      body: jsonEncode(
          {
            "name":"${namecontroller.text}",
            "username":"${userNamecontroller.text}",
            "password":"${passwordcontroller.text}"
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
          widget.users.add(responsebody);
          Navigator.pop(context,widget.users);
          isloading = true;
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
        title: Text('Create User'),
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
                Text('Name',style: TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.w500,
                ),),
                height(15),
                DefaultTextfiled(
                  maxLines: 1,
                  label: "Name",
                  controller: namecontroller,
                  hintText: 'User Name',
                  keyboardType: TextInputType.text,
                ),
                height(20),
                Text('User Name',style: TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.w500,
                ),),
                height(15),
                DefaultTextfiled(
                  maxLines: 1,
                  label: "User Name",
                  controller: userNamecontroller,
                  hintText: 'User Name',
                  keyboardType: TextInputType.text,
                ),
                height(20),
                Text('Password',style: TextStyle(
                  fontSize: 16,
                  fontWeight:FontWeight.w500,
                ),),
                height(15),
                DefaultTextfiled(
                  maxLines: 1,
                  label: "Password",
                  controller: passwordcontroller,
                  hintText: 'Password',
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
                        CreateUser();
                      }
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:BorderRadius.circular(5),
                      ),
                      child:Center(child:isloading? Text('Create User',style: TextStyle(
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
