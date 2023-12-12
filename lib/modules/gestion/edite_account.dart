import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/remote/cachehelper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/components/components.dart';

class EditeAccont extends StatefulWidget {
  var name;
  var about;
  var email;
  var description;
  var id;
  var image;
   EditeAccont({Key key, this.name, this.about,this.email,this.description,this.id,this.image}) : super(key: key);

  @override
  State<EditeAccont> createState() => _EditeAccontState();
}

class _EditeAccontState extends State<EditeAccont> {
  File _image;
  String img64;
  Uint8List bytes;
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        bytes =File(pickedFile.path).readAsBytesSync();
        img64 = base64Encode(bytes);
        EditeImage(img64:img64);
      });
    }
  }
  @override
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  bool isloading = true;
  bool isImageloading = true;
  var namecontroller = TextEditingController();
  var descriptioncontroller = TextEditingController();
  var emailcontroller = TextEditingController();
  var aboutcontroller = TextEditingController();
  String access_token = Cachehelper.getData(key:"token");

  Future EditeAccount() async {
    setState(() {
      isloading = false;
    });
    final response = await http.put(
      Uri.parse('https://wechat.canariapp.com/api/v1/accounts/${widget.id}'),
      body:jsonEncode(
          {
            "description":"${descriptioncontroller.text}",
            "email":"${emailcontroller.text}",
            "about":"${aboutcontroller.text}",
            "name":"${namecontroller.text}"
          }
      ),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization':'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);
        print('--------------------------------------');

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

  Future EditeImage({img64}) async {
    setState(() {
      isImageloading = false;
    });
    final response = await http.put(
      Uri.parse('https://wechat.canariapp.com/api/v1/accounts/${widget.id}/profile_picture'),
      body:jsonEncode(
          {
            "image":"${img64}"
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
          isImageloading = true;
        });
      }else{
        var responsebody = jsonDecode(value.body);
        setState((){
          printFullText(responsebody.toString());
          isImageloading = true;
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
  descriptioncontroller.text = widget.description;
  emailcontroller.text = widget.email;
  aboutcontroller.text = widget.about;
    super.initState();
  }


  @override
  Widget build(BuildContext context){


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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        maxRadius: 60,
                        backgroundImage:_image != null ? FileImage(_image):widget.image==null?NetworkImage('https://www.pngitem.com/pimgs/m/35-350426_profile-icon-png-default-profile-picture-png-transparent.png'):NetworkImage('${widget.image}'),
                      ),
                      CircleAvatar(
                        maxRadius: 21.5,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          child:isImageloading?IconButton(
                              splashRadius: 25,
                              onPressed: (){
                                _pickImage(ImageSource.gallery).then((value){

                                });
                              }, icon:Icon(Icons.camera_alt_outlined,size: 23)):Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(color: Colors.white,strokeWidth: 3),
                              ),
                        ),
                      )
                    ],
                  ),
                  height(25),
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
                    child: Text('Description',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(15),
                  DefaultTextfiled(
                    maxLines: 3,
                    label: "Description",
                    controller:descriptioncontroller,
                    hintText: 'Description',
                    keyboardType: TextInputType.text,
                  ),
                  height(20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('About',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(15),
                  DefaultTextfiled(
                    maxLines: 1,
                    label: "About",
                    controller:aboutcontroller,
                    hintText: 'About',
                    keyboardType: TextInputType.text,
                  ),
                  height(20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('Email',style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.w500,
                    ),),
                  ),
                  height(15),
                  DefaultTextfiled(
                    maxLines: 1,
                    label: "Email",
                    controller:emailcontroller,
                    hintText: 'Email',
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
                          EditeAccount();
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
