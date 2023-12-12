import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../Widget/audio_bar.dart';
import '../../shared/components/components.dart';
import '../../shared/remote/cachehelper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sound/flutter_sound.dart';

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
class ChatScreen extends StatefulWidget {
  final account;
  final sender;
  final user;
  final receiver_id;
  final name;
  const ChatScreen({Key key,this.account,this.sender,this.user, this.receiver_id, this.name}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isShowSendButton = false;
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

      });
    }
  }
  String recordFilePath;
  void play() async{
    // print(recordFilePath);
    recordFilePath = await getFilePath();
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath, isLocal: true);
    }
  }

  int i = 0;
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    print('----------------------------');
    print(sdPath);
    print('----------------------------');

    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    List<int> mp3Bytes = await readMP3File(sdPath + "/test_${i++}.mp3");
    base64String = convertMP3ToBase64(mp3Bytes);
    var audio = sdPath + "/test_${i++}.mp3";
    print('----------------------------------------------=>');
    print(audio);
    print('----------------------------------------------=>');
    return sdPath + "/test_${i++}.mp3";

  }
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
  String statusText = "";
  bool isComplete = false;

  AudioPlayer audioPlayer = new AudioPlayer();
  bool isplaying = false;
  bool isSearch = false;
  List templateFilter = [];
  List list = [];
  void filterTemplate(value){
    setState(() {
      templateFilter = list.where((element) => element['name'].toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  List<VariableController> controllers;
   var text = "";
   bool isTemplateShow = false;
   bool isSendTemplateShow = false;
   ScrollController _scrollController = ScrollController();
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
        list = templateFilter = Templates;
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
  DateTime now = DateTime.now();
  final send = GlobalKey();
  final received = GlobalKey();
  TextEditingController chatController = TextEditingController();
  IO.Socket socket;
  var chatMessage = [];
  void scrollToEnd()async{
    await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut);
  }
  void scrollToTop() async {
    await _scrollController.animateTo(
        1000,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut);
        Scrollable.ensureVisible(received.currentContext);
  }


  Future<void> getConversation()async{
    print('getConversationLoading');
   setState(() {
     isloading = false;
   });
    final response = await http.get(
      Uri.parse('https://wechat.canariapp.com/api/v1/conversation?receiver=${widget.receiver_id}&sender=${widget.sender}'),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',},
    ).then((value){
      if(value.statusCode==200){
        var responsebody = jsonDecode(value.body);
        print('data :${responsebody}');
        chatMessage = responsebody;
        print(responsebody);
        setState(() {
          isloading = true;
        });
      }else{
        setState(() {
          var responsebody = jsonDecode(value.body);
          print(responsebody);
          isloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }
  var Tamplet;

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      setState(() {});
    }
  }
  void sendMessage({message}){
    String formattedTime = now.toUtc().toIso8601String();
    int randomDigits = Random().nextInt(9000) + 1000;
    String reference = '${randomDigits}usd';
    print(reference);
    var messageJson = {
      "reference":reference,
      "message_type":"text",
      "message":{
        "body":"${message}"
      },
      "sender_id":widget.sender,
      "receiver_id":widget.receiver_id,
    };

    var Message = {
      "message_type":"text",
      "message":{
        "body":"${message}"
      },
      "sender":widget.sender,
      "receiver":widget.receiver_id,
      "status":"pending",
      "timestamp":"${formattedTime}"
    };

    chatMessage.add(Message);

    socket.emit('send-message',messageJson);
    if (mounted) {
      setState(() {
        SchedulerBinding.instance.addPostFrameCallback((_) => scrollToEnd());
      });
    }











  }

  bool isSend = true;
  bool isSendTemplate = true;
  bool isAudioSend = true;
  bool isTamplet = false;
  bool isImage = false;

  void ChangeStatusListener(){
    socket.on("message-status-changed", (data) {
      String messageId = data['_id'];
      String status = data['status'];
      for (var message in chatMessage) {
        if (message['_id'] == messageId){
          if (mounted) {
            setState(() {
              message['status'] = status;
            });
          }
          break;
        }
      }
    });
  }

  void connectToSocket() {
    socket = io('https://wechat.canariapp.com',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()  // disable auto-connection
            .setExtraHeaders({'token':'${access_token}'}) // optional
            .build()
    );
    socket.connect();
    ChangeStatusListener();
    socket.onConnect((data){
      print('connected');
      socket.on("message-received",(payload){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              print('----------------------------------------------->');
              print('${payload}');
              print('----------------------------------------------->');
              chatMessage.add(payload);
              scrollToTop();
            });
          }
        });

      });

      socket.emit('read-message',{"receiver_id":"${widget.sender}","sender_id":"${widget.receiver_id}"});

      socket.on("message-sent-successfully",(payload){
        if (mounted) {
          setState(() {
            if(isImage!=true){
              chatMessage.remove(chatMessage.last);
              chatMessage.add(payload['chat']);
            }else{
              print('tamplate');
              chatMessage.add(payload['chat']);
              isSend = true;
              isSendTemplate = true;
              isAudioSend = true;
            }
            if(isTamplet!=true){
              chatMessage.remove(chatMessage.last);
              chatMessage.add(payload['chat']);
            }else{
              print('tamplate');
              chatMessage.remove(chatMessage.last);
              chatMessage.add(payload['chat']);
              setState(() {
                isSend = true;
                isSendTemplate = true;
                isAudioSend = true;
              });
            }
          });
        }
      });
    });
  }

  void pauseRecord() async{
    if (RecordMp3.instance.status == RecordStatus.PAUSE) {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "Recording...";
        setState(() {});
      }
    } else {
      bool s = RecordMp3.instance.pause();
      if (s) {
        statusText = "Recording pause...";
        recordFilePath = await getFilePath();
        setState(() {});
      }
    }
  }

  var byte;
  readMP3File(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      byte = await file.readAsBytes();
      return byte;
    } else {
      setState(() {
        statusText = "File not found";
      });
      throw Exception("File not found: $filePath");
    }
  }
  String base64String;

  String convertMP3ToBase64(mp3Byte){
    base64String = "";
    base64String = base64Encode(mp3Byte);
    return base64String;
  }

  Future SendMessageImage({payload})async{
    setState(() {
      print('sendImageLoading');
      isSend =false;
    });
    final response = await http.post(
      Uri.parse('https://wechat.canariapp.com/api/v1/send_message'),
      body:jsonEncode(payload),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        chatMessage.add(data);
        setState(() {
          isSend =true;
        });
      }else{
        setState(() {
          print(value.body);
          isSend =true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  Future SendMessageAudio({payload})async{
    setState(() {
      print('sendAudioLoading');
      isAudioSend = false;

    });
    final response = await http.post(
      Uri.parse('https://wechat.canariapp.com/api/v1/send_message'),
      body:jsonEncode(payload),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        chatMessage.add(data);
        isAudioSend = true;
        setState(() {
        });
      }else{
        setState(() {
          print(value.body);
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }



  FlutterSoundRecorder _recorder;

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if(status!= PermissionStatus.granted){
    throw 'Microphone permission not granted';
    }
    await _recorder.openRecorder();
  }


  Future<void> startRecording() async {
    await _recorder.startRecorder(toFile:"audio");
    setState(() {
       statusText = "Recording...";
    });
  }

  Future stopRecording() async {
   final path = await _recorder.stopRecorder();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        base64String = base64Encode(bytes);
        setState(() {
          statusText = "Recording pause...";
        });
        print('bytes is : ${base64String}');
        return base64String;
      }
    }
    return null;
  }




  @override
  void initState() {
    _recorder = FlutterSoundRecorder();
    statusText = '';
    initRecorder();
    getConversation();
    connectToSocket();
    super.initState();
  }

  @override
  void dispose() {
    socket.disconnect();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){

    return WillPopScope(
        onWillPop: ()async{
          setState(() {
            if(isTemplateShow){
              isTemplateShow = false;
              isSendTemplateShow = false;
            }else{
              Navigator.pop(context,chatMessage.last);
            }

          });
          return false;
        },
      child: Scaffold(
        appBar:!isSendTemplateShow?!isTemplateShow?AppBar(
          toolbarHeight: 65,
          backgroundColor:Color(0xFF075e54),
          elevation: 0,
           leading:Padding(
             padding: const EdgeInsets.only(left: 5),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 InkWell(
                     onTap: (){
                       setState(() {
                         if(chatMessage.length>0){
                           widget.account['lastMessage']['message_type'] = chatMessage.last['message_type'];
                           widget.account['lastMessage']['message'] =chatMessage.last['message'];
                           widget.account['lastMessage']['receiver'] = chatMessage.last['sender'];
                           widget.account['_id'] = chatMessage.last['receiver'];
                           widget.account['lastMessage']['status'] = chatMessage.last['status'];
                           widget.account['lastMessage']['timestamp'] = chatMessage.last['timestamp'];
                           widget.account['unreadCount'] = 0;
                            print(widget.account);
                            print(chatMessage.last);
                             Navigator.pop(context,widget.account);
                         }else{
                             Navigator.pop(context,widget.account);
                         }
                       });
                     },
                     child: Icon(Icons.arrow_back,size: 26,)),
                 SizedBox(width: 3,),
                 ClipRRect(
                   child: Image.asset('assets/default.png',height: 40,width: 40,),
                 ),
               ],
             ),
           ),
          leadingWidth: 80,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.account['contact']['name']}',style: TextStyle(fontSize: 16),),
            ],
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                    onTap: (){},
                    child: Icon(Icons.more_vert_rounded,color: Colors.white,))
            )
          ],
        ):AppBar(
          toolbarHeight: 65,
          backgroundColor:Color(0xFF075e54),
          elevation: 0,
          leading:InkWell(
              onTap: (){
                setState(() {
                  isTemplateShow = false;
                  isSendTemplateShow = false;

                });
              },
              child: Icon(Icons.arrow_back,size: 26,)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child:isSearch == false?
              GestureDetector(
                  onTap: (){
                    setState(() {
                      isSearch = true;
                    });
                  },
                  child:Icon(Icons.search,color: Colors.white,)):GestureDetector(
                  onTap: (){
                    setState(() {
                      isSearch = false;
                      templateFilter = list;
                    });
                  },
                  child:isSearch == false? Icon(Icons.search,color: Colors.white,):Icon(Icons.close,color: Colors.white,)),
            ),
          ],
          title:isSearch == false? Text('Templates',style: TextStyle(color: Colors.white),
          ):TextField(
            decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.white,
                )
            ),
            autofocus:true,
            style: TextStyle(color: Colors.white),
            onChanged: (value){
              filterTemplate(value);
            },
          ),
        ):AppBar(
          toolbarHeight: 65,
          backgroundColor:Color(0xFF075e54),
          elevation: 0,
          leading:InkWell(
              onTap: (){
                setState(() {
                  isTemplateShow = false;
                  isSendTemplateShow = false;
                });
              },
              child: Icon(Icons.arrow_back,size: 26,)),
          title: Text('Send Template',style: TextStyle(color: Colors.white),
          ),
        ),
        body:isSendTemplateShow?
        SingleChildScrollView(
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
                              ...Tamplet['payload'].map((payload){
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
                  itemCount:Tamplet['payload'].length,
                  itemBuilder: (context,index){
                    final List<VariableController> controllers = createVariableControllers(Tamplet['payload'][index]['parameters'].length);
                    String capitalized = Tamplet['payload'][index]['type'][0].toUpperCase() + Tamplet['payload'][index]['type'].substring(1).toLowerCase();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[

                        if(Tamplet['payload'][index]['parameters'].length>0)
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
                              maxLines:Tamplet['payload'][index]['type']=='BODY'?3:1,
                              onChanged: (value) {
                                setState(() {
                                  Tamplet['payload'][index]['parameters'][i]['text'] = value;
                                });
                              },
                              decoration: InputDecoration(
                                  labelStyle: TextStyle(color:Color(0xff9BABB8)),
                                  labelText: 'Entre your content for ${Tamplet['payload'][index]['type'].toLowerCase()}',
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
             height(MediaQuery.of(context).size.height/ 40),
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20),
                child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: TextButton(onPressed: (){
                      setState(() {
                        int randomDigits = Random().nextInt(9000) + 1000;
                        String reference = '${randomDigits}usd';
                    var json = {
                        "reference":reference,
                        "message_type":"template",
                        "message":{
                          "name":Tamplet['name'],
                          "language":{
                            "code":Tamplet['language'],
                          },
                          "components":Tamplet['payload'].map((component) {
                            return component["parameters"].length>0?{
                              'type':component['type'].toLowerCase(),
                              'parameters':component['parameters']
                            }:null;
                          }).where((element) => element != null).toList()
                        },
                        "sender_id":widget.sender,
                        "receiver_id":widget.receiver_id,
                        };
                        isSendTemplate = false;
                        isTamplet = true;
                        chatMessage.add(json);
                        socket.emit('send-message',json);
                        isTemplateShow = false;
                        isSendTemplateShow = false;
                      });}, child:isSend?Row(
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
                    ):CircularProgressIndicator(color: Colors.white,))),
              )
            ],

          ),
        ):isTemplateShow?
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
                  templateFilter.length>0 ?
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:templateFilter.length,
                      itemBuilder: (context,index){
                        return Align(
                            alignment: AlignmentDirectional.topStart,
                            child:ConstrainedBox(
                              constraints:BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width - 60
                              ),
                              child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    isSendTemplateShow = true;
                                    Tamplet = templateFilter[index];
                                  });
                                  },
                                child: Card(
                                  color: Color(0xFFdcf8c6),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...templateFilter[index]['components'].map((component){
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
                      }):
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
                                  setState(() {
                                    isSendTemplateShow = true;
                                    Tamplet = Templates[index];
                                  });
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
        ):
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/background.jpg'),fit: BoxFit.cover)
          ),
          child:chatMessage.length>0?SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 10,left: 8,right: 8,bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  ListView.builder(
                      itemCount:chatMessage.length,
                      shrinkWrap:true,
                      reverse:false,
                      physics:NeverScrollableScrollPhysics(),
                      itemBuilder:(context,index){
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.sender == chatMessage[index]['sender'] ?
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
                                      if(chatMessage[index]['message_type']=='text')
                                        Padding(padding: EdgeInsets.only(left: 10,right: 60,top: 6,bottom: 0),
                                          child:  Text("${widget.name}",style: TextStyle(color:Colors.red,fontSize: 11.0,fontWeight: FontWeight.w500)),
                                        ),
                                      if(chatMessage[index]['message_type']=='text')
                                        Padding(padding: EdgeInsets.only(left: 10,right: 60,top: 20,bottom: 20),
                                          child: Text('${chatMessage[index]['message']['body']}',style:TextStyle(
                                              fontSize: 16
                                          )),
                                        ),
                                      if(chatMessage[index]['message_type']=='text')
                                        Positioned(
                                            bottom: 1,
                                            right: 10,
                                            child: Row(
                                              children: [
                                                Text('${DateTime.parse(chatMessage[index]['timestamp']).hour}:${DateTime.parse(chatMessage[index]['timestamp']).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),),
                                                SizedBox(width: 5,),
                                                buildStatus(chatMessage[index]['status'])
                                              ],
                                            )),
                                      if(chatMessage[index]['message_type']=='image')
                                        Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                            child:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if(chatMessage[index]['message_type']=='image')
                                                Image.network('${chatMessage[index]['message']['link']}'),
                                                height(5),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text('${DateTime.parse(chatMessage[index]['timestamp']).hour}:${DateTime.parse(chatMessage[index]['timestamp']).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),),
                                                    SizedBox(width: 5,),
                                                    buildStatus(chatMessage[index]['status'])
                                                  ],
                                                )
                                              ],
                                            )
                                        ),

                                      if(chatMessage[index]['message_type']=='template')
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(padding: EdgeInsets.only(left: 0,right: 60,top: 6,bottom: 5),
                                                child:  Text("${widget.name}",style: TextStyle(color:Colors.red,fontSize: 11.0,fontWeight: FontWeight.w500)),
                                              ),
                                              Text("${chatMessage[index]['message']['header']}",style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),

                                              Text('${chatMessage[index]['message']['body']}',style:TextStyle(
                                                  fontSize: 16
                                              )),
                                              Text("${chatMessage[index]['message']['footer']}",style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey[600]
                                              )),
                                              if(chatMessage[index]['message_type']=='template')
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text('${DateTime.parse(chatMessage[index]['timestamp']).hour}:${DateTime.parse(chatMessage[index]['timestamp']).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),),
                                                    SizedBox(width: 5,),
                                                    buildStatus(chatMessage[index]['status'])
                                                  ],
                                                )
                                            ],
                                          ),
                                        ),
                                      if(chatMessage[index]['message_type']=='audio')
                                        Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 15,top: 0,bottom: 20),
                                            child:Column(
                                              children: [
                                                IconButton(onPressed: ()async{
                                                  print(chatMessage[index]['message']['link']);
                                                  chatMessage.map((e){
                                                    setState(() {
                                                      e['is_loading'] = false;
                                                      print(e['is_loading']);
                                                    });
                                                  });

                                                  if(chatMessage[index]['is_loading']==false){
                                                    chatMessage.forEach((e){
                                                      setState(() {
                                                        e['is_loading'] = false;
                                                      });
                                                    });
                                                    setState(() {
                                                      chatMessage[index]['is_loading'] = true;
                                                      print(chatMessage[index]['is_loading']);
                                                    });
                                                    var res = await audioPlayer.play(chatMessage[index]['message']['link'],isLocal: true);
                                                    print(res);
                                                  }else{
                                                    print('pause');
                                                    chatMessage.forEach((e){
                                                      setState(() {
                                                        e['is_loading'] = false;
                                                      });
                                                    });


                                                    var res = await audioPlayer.pause();
                                                    print(res);
                                                  }

                                                },icon:Icon(chatMessage[index]['is_loading']?
                                                Icons.pause
                                                    :
                                                Icons.play_arrow_rounded,size: 45,color: Color(0xFF9c8d8d),)),
                                              ],
                                            )
                                        ),

                                      if(chatMessage[index]['message_type']=='audio')
                                        Positioned(
                                            bottom: 4,
                                            right: 10,
                                            child: Row(
                                              children: [
                                                Text('${DateTime.parse(chatMessage[index]['timestamp']).hour}:${DateTime.parse(chatMessage[index]['timestamp']).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),),
                                                SizedBox(width: 5,),
                                                buildStatus(chatMessage[index]['status'])
                                              ],
                                            )),


                                    ],
                                  ),
                                ),
                              ),
                            ) : ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width - 45
                              ),
                              child: Card(
                                color: Color(0xFFFFFFFF),
                                elevation: 1,
                                child:Stack(
                                  children:[
                                    if(chatMessage[index]['message_type']=='text')
                                      Padding(padding: EdgeInsets.only(left: 10,right: 60,top: 10,bottom: 20),
                                        child: Text('${chatMessage[index]['message']['body']}',style: TextStyle(
                                            fontSize: 16
                                        )),
                                      ),
                                    if(chatMessage[index]['message_type']=='text')
                                    Positioned(
                                        bottom: 4,
                                        right: 10,
                                        child: Text('${DateTime.parse(chatMessage[index]['timestamp']).hour}:${DateTime.parse(chatMessage[index]['timestamp']).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),)),
                                    if(chatMessage[index]['message_type']=='image')
                                      Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                          child:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if(chatMessage[index]['message_type']=='image')
                                                Image.network('${chatMessage[index]['message']['url']}'),
                                              height(5),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text('${DateTime.parse(chatMessage[index]['timestamp']).hour}:${DateTime.parse(chatMessage[index]['timestamp']).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),),
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                    if(chatMessage[index]['message_type']=='audio')
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 15,top: 0,bottom: 20),
                                        child:Column(
                                          children: [
                                            IconButton(onPressed: ()async{
                                              chatMessage.map((e){
                                               setState(() {
                                                 e['is_loading'] = false;
                                                 print(e['is_loading']);
                                               });
                                              });

                                             if(chatMessage[index]['is_loading']==false){
                                               chatMessage.forEach((e){
                                                 setState(() {
                                                   e['is_loading'] = false;
                                                 });
                                               });
                                               setState(() {
                                                 chatMessage[index]['is_loading'] = true;
                                                 print(chatMessage[index]['is_loading']);
                                               });
                                               var res = await audioPlayer.play(chatMessage[index]['message']['url'],isLocal: true);
                                               print(res);
                                             }else{
                                               print('pause');
                                               chatMessage.forEach((e){
                                                 setState(() {
                                                   e['is_loading'] = false;
                                                 });
                                               });
                                               var res = await audioPlayer.pause();
                                               print(res);
                                             }
                                            },icon:Icon(chatMessage[index]['is_loading']?
                                            Icons.pause
                                             :
                                            Icons.play_arrow_rounded,size: 45,color: Color(0xFF9c8d8d),)),
                                          ],
                                        )
                                      ),
                                    if(chatMessage[index]['message_type']=='audio')
                                      Positioned(
                                          bottom: 4,
                                          right: 10,
                                          child: Text('${DateTime.parse(chatMessage[index]['timestamp']).hour}:${DateTime.parse(chatMessage[index]['timestamp']).minute}',style: TextStyle(fontSize: 11,color: Colors.grey[600]),)),
                                  ],
                                ),
                              ),
                            ),
                          ]
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
        ),


        bottomSheet:!isTemplateShow?Container(
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
                      onChanged: (value){
                        if(chatController.text.length>0){
                          setState(() {
                            isShowSendButton = true;
                          });
                        }else{
                          setState(() {
                            isShowSendButton = false;
                          });
                        }

                      },
                      controller: chatController,
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
                                  onPressed: (){
                                    showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context, builder: (context)=>BottonSheet());
                                  }, icon: Icon(Icons.attachment_rounded)),
                                 IconButton(
                                  splashRadius: 25,
                                  onPressed: (){
                                    _pickImage(ImageSource.gallery).then((value){
                                      SendMessageImage(
                                        payload: {
                                          "message_type":"image",
                                          "message":{
                                            "image":"${img64}"
                                          },
                                          "sender_id":widget.sender,
                                          "receiver_id":widget.receiver_id,
                                        }
                                      );
                                     setState(() {
                                       isImage = true;
                                     });
                                    });
                                  }, icon:Icon(Icons.camera_alt_outlined))
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
                  child:isSend?isShowSendButton?IconButton(
                      splashRadius: 25,
                      onPressed: (){
                        setState(() {
                          isTamplet = false;
                          isImage = false;
                        });
                       sendMessage(message:chatController.text);
                       chatController.clear();
                      },icon:Icon(Icons.send,color: Colors.white,))
                      :
                  IconButton(onPressed: (){
                    audioPlayer.stop();
                    showModalBottomSheet(context: context, builder: (context){
                      return AudioBar(
                        chatMessage: chatMessage,
                        sender: widget.sender,
                        receiver_id: widget.receiver_id,
                      );
                    });
                  },icon: Icon(Icons.mic,color: Colors.white,)):SpinKitRing(
                    lineWidth: 3,
                    color:Colors.white,
                    size: 50.0,
                  ),
                )
              ],
            ),
          ),
        ):null
      ),
    );
  }


  Widget BottonSheet(){
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
       child: Card(
         margin: EdgeInsets.all(18),
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
           child: Column(
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   iconcreation(icon:Icons.camera_alt,color: Colors.red,title:'Camera',onTap: (){}),
                   SizedBox(width: 40,),
                   iconcreation(icon:Icons.image,color: Colors.deepPurple,title:'Gallery',onTap: (){}),
                   SizedBox(width: 40,),
                   iconcreation(icon:Icons.audiotrack_outlined,color: Colors.deepOrange,title:'Audio',onTap: (){}),
                 ],
               ),
               SizedBox(height: 30,),
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   iconcreation(icon:Icons.person,color: Colors.blue,title:'Account',onTap: (){}),
                   SizedBox(width: 40,),
                   iconcreation(icon:Icons.location_on,color: Colors.green,title:'Location',onTap: (){}),
                   SizedBox(width: 40,),
                   iconcreation(icon:Icons.message,color: Colors.cyan,title:'Template',onTap: (){
                     print('Template');
                     Navigator.pop(context);
                    setState(() {
                      getTemplates();
                      isTemplateShow = true;
                    });
                   }),
                 ],
               ),
             ],
           ),
         ),
       ),
    );
  }

  Widget iconcreation({IconData icon,Color color,String title,Function onTap}){
    return GestureDetector(
      onTap:onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:color,
            child: Icon(icon,size: 29,color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(title,style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w300
          ),)

        ],
      ),
    );
  }

  Future<String> convertAudioFileToBase64(filePath) async {
    try {
      // Read the audio file
      final file = File(filePath);
      List<int> audioBytes = await file.readAsBytes();

      // Encode the audio data as Base64
      String base64AudioData = base64Encode(audioBytes);

      return base64AudioData;
    } catch (e) {
      print('Error converting audio file to Base64: $e');
      return null;
    }
  }

}
