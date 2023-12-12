import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/remote/cachehelper.dart';
import '../../shared/components/components.dart';

class EditeUser extends StatefulWidget {
  final name;
  final password;
  final id;
  const EditeUser({Key key, this.name, this.password, this.id}) : super(key: key);

  @override
  State<EditeUser> createState() => _EditeUserState();
}

class _EditeUserState extends State<EditeUser> {

  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  bool isloading = true;
  bool isAccountloading = true;
  var namecontroller = TextEditingController();
  var passwordController = TextEditingController();
  String access_token = Cachehelper.getData(key:"token");
  List accounts = [];
  List _groups = [];

  Future getAccounts() async {
    isAccountloading = false;
    final response = await http.get(
      Uri.parse('https://wechat.canariapp.com/api/v1/accounts'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);
        print('--------------------------------------');
        accounts = responsebody;
        accounts.forEach((element){
          _groups.add(element['_id']);
        });
        print('--------------------------------------');

        setState(() {
          isAccountloading = true;
        });
      }else{
        var responsebody = jsonDecode(value.body);
        setState(() {
          print('${responsebody}');
          isAccountloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }
  List _selectedItems = [];
  void _toggleItem(item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, stateState){
              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text('select Account'),
                  content: SingleChildScrollView(
                    child:isAccountloading? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _groups.map((item) {
                        return CheckboxListTile(
                          title: Text('${item}'),
                          value: _selectedItems.contains(item),
                          onChanged: (bool value) {
                            stateState(() {
                              _toggleItem(item);
                            });
                          },
                        );
                      }).toList(),
                    ):Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator()
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Select'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }
  Future EditeUser() async {
    setState(() {
      isloading = false;
    });
    final response = await http.put(
      Uri.parse('https://wechat.canariapp.com/api/v1/users/${widget.id}'),
      body:jsonEncode(
          {
            "name":"${namecontroller.text}",
            "password":"${passwordController.text}",
            "accounts":_selectedItems
          }
      ),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization':'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);
        print('--------------------------------------');
         print(responsebody);
        print('--------------------------------------');

        setState(() {
          Navigator.pop(context,responsebody);
          isloading = true;
        });
      }else{
        var responsebody = jsonDecode(value.body);
        setState(() {
          printFullText(responsebody.toString());
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
    namecontroller.text = widget.name;
    passwordController.text = widget.password;
    getAccounts();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation:0,
        backgroundColor:Color(0xFF075e54),
        title: Text('Edite Account'),
      ),
      body:SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.only(top: 25,left:15,right:15),
            child: Form(
              key: fromkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  height(35),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Name',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(15),
                  DefaultTextfiled(
                    maxLines: 1,
                    label: "Name",
                    controller:namecontroller,
                    hintText: 'Name',
                    keyboardType: TextInputType.text,
                  ),
                  height(15),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Password',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(15),
                  DefaultTextfiled(
                    maxLines: 1,
                    label: "Password",
                    controller:passwordController,
                    hintText: 'Password',
                    keyboardType: TextInputType.text,
                  ),
                  height(15),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('select Account',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(10),
                  GestureDetector(
                    onTap: (){
                      _showAlertDialog(context);
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 1,
                            color: Color(0xff9BABB8),
                          )
                      ),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('select Account'),
                          ),
                          IconButton(
                              splashRadius: 10,
                              onPressed: (){
                                _showAlertDialog(context);
                              }, icon:Icon(Icons.arrow_drop_down))
                        ],
                      ) ,
                    ),
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
                          EditeUser();
                        }
                      },
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius:BorderRadius.circular(5),
                        ),
                        child:Center(child:isloading? Text('Edite Account',style: TextStyle(
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
      ),
    );
  }
}
