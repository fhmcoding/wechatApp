import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/remote/cachehelper.dart';
import '../gestion/create_account.dart';
import '../gestion/edite_account.dart';

class Accounts extends StatefulWidget {
  const Accounts({Key key}) : super(key: key);

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  var Account;
  bool isloading = true;
  bool isdeletloading = true;
  String access_token = Cachehelper.getData(key:"token");
  List accounts = [];
  Future getAccounts() async {
    isloading = false;
    final response = await http.get(
      Uri.parse('https://wechat.canariapp.com/api/v1/accounts'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);

        print('--------------------------------------');
        accounts = responsebody;
        print('--------------------------------------');

        setState(() {
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
  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, stateState){
              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  title: Text(''),
                  content: SingleChildScrollView(
                    child:isdeletloading?Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                      ],
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
                      child: Text(''),
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
  Future deletAccount({id})async {
    setState(() {
      isdeletloading = false;
      _showAlertDialog(context);
    });
    final response = await http.delete(
      Uri.parse('https://wechat.canariapp.com/api/v1/accounts/${id}'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);
        print('--------------------------------------');
        responsebody;
        print('--------------------------------------');

        setState(() {
          isdeletloading = true;
          accounts.removeWhere((element) => element["_id"]==id);
          Navigator.of(context).pop();
        });
      }else{
        var responsebody = jsonDecode(value.body);
        setState(() {
          print('${responsebody}');
          isdeletloading = true;
          Navigator.of(context).pop();
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  @override
  void initState() {
    getAccounts();
    super.initState();
  }

  void NavigatAccounts()async{
    var Accounts = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccount(accounts:accounts)));
    setState(() {
      if(Accounts!=null){
        accounts = Accounts;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation:0,
        backgroundColor:Color(0xFF075e54),
        title: Text('Accounts'),
        actions: [
          PopupMenuButton<String>(
            onSelected:(value){
              if(value == 'CreateAccount'){
               setState(() {
                 NavigatAccounts();
               });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'CreateAccount',
                  child: Text('Create Account'),
                ),
              ];
            },
          )
        ],
      ),
      body: isloading?SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: accounts.length,
                itemBuilder: (context,index){

                var account = accounts[index];

                if(Account!=null){
                  if(account['_id']==Account['_id']){
                    account = Account;
                  }
                }

                return Padding(
                padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
                child:Card(
                  elevation:2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15,top: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:BorderRadius.circular(50),
                                  color: Colors.grey
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child:account['image']==null?Image.asset('assets/default.png',height: 60,width:60,):Image.network('${account['image']}',height: 60,width:60,fit: BoxFit.cover),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${account['name']}',style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff252B48)
                                  )),
                                  Text('${account['phone_number']}',style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff61677A)
                                  ),)
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                  height: 35,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.blue
                                  ),
                                  child:TextButton(onPressed: ()async{
                                    Account = await Navigator.push(context, MaterialPageRoute(builder: (context)=>EditeAccont(
                                      name:account['name'],
                                      about:account['about'],
                                      email:account['email'],
                                      description:account['description'],
                                      id:account['_id'],
                                      image:account['image']
                                    )));

                                   setState(() {
                                    print('------------------------------>');
                                    print(Account);
                                    print('------------------------------>');
                                   });

                                  }, child:Text('Edite',style: TextStyle(color: Colors.white),))),
                              SizedBox(width: 10,),
                              Container(
                                  height: 35,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      color:Colors.red,
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: TextButton(onPressed: (){
                                    deletAccount(id:account['_id']);
                                  }, child:Text('Delete',style:TextStyle(color: Colors.white))))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            })
          ],
        ),
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
