import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../shared/components/components.dart';
import '../shared/remote/cachehelper.dart';

class AudioBar extends StatefulWidget {
  final chatMessage;
  final sender;
  final receiver_id;

  const AudioBar({Key key, this.chatMessage, this.sender, this.receiver_id,}) : super(key: key);

  @override
  State<AudioBar> createState() => _AudioBarState();
}

class _AudioBarState extends State<AudioBar> {
  String statusText = "";
  String access_token = Cachehelper.getData(key:"token");
  bool isAudioSend = true;
  Future SendMessageAudio({payload})async{
    setState(() {
      print('sendAudioLoading');
      statusText = 'Audio Sending ...';
      isAudioSend = false;

    });
    final response = await http.post(
      Uri.parse('https://wechat.canariapp.com/api/v1/send_message'),
      body:jsonEncode(payload),
      headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}'},
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        printFullText(data.toString());
        widget.chatMessage.add(data);
        isAudioSend = true;
        Navigator.pop(context);
        _recorder.closeRecorder();
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
  String base64String;
  Future convertBase64ToAudioFile(String base64String, String filePath) async {
    try {
      // Decode the Base64 string
      List<int> audioBytes = base64Decode(base64String);

      // Ensure the directory exists before writing the file
      Directory directory = File(filePath).parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create a File and write the decoded bytes to it
      File audioFile = File(filePath);
      await audioFile.writeAsBytes(audioBytes);
        print(audioFile);
      return true; // Success
    } catch (e) {
      print('Error converting Base64 to audio: $e');
      return false; // Error
    }
  }
  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if(status!= PermissionStatus.granted){
      throw 'Microphone permission not granted';
    }
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(Duration(microseconds: 500));
    startRecording();
  }

  bool isRecording = false;
  Future<void> startRecording() async {
    await _recorder.startRecorder(toFile:"audio");
    setState(() {
      isRecording = false;
      statusText = "Recording...";
    });
  }
  Uint8List bytes;
  Future stopRecording() async {
    final path = await _recorder.stopRecorder();
    if (path != null) {
      final file = File(path);
      if (await file.exists()){
        bytes = File(file.path).readAsBytesSync();
        base64String = base64Encode(bytes);
        printFullText(base64String);
        setState(() {
          isRecording = true;
          statusText = "Recording pause...";
        });
        return base64String;
      }
    }
    return null;
  }
  Future<void> StopRecording() async {
    if (isRecording) {
      final path = await _recorder.stopRecorder();
      setState(() {
        isRecording = false;
        statusText = "Recording stopped";

        // Read the recorded audio file
        List<int> audioBytes = File(path).readAsBytesSync();

        // Convert the audio data to a Base64 string
        base64String = base64Encode(audioBytes);

        // Print the Base64 string
        print("Base64 String: $base64String");
      });
    }
  }

  @override
  void initState() {
    _recorder = FlutterSoundRecorder();
    statusText = '';
    initRecorder();
    super.initState();
  }
@override
  void dispose() {
   _recorder.closeRecorder();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${statusText}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                  Text('')
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20,right: 20,left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    elevation: 5,
                    color:Colors.grey[400],
                    shadowColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child:IconButton(onPressed: (){
                      Navigator.pop(context);
                      statusText = '';
                      _recorder.closeRecorder();
                      setState(() {

                      });
                    }, icon:Icon(Icons.delete,color: Colors.white,)),
                  ),
                 Stack(
                   alignment: Alignment.center,
                   children: [
                     SpinKitDoubleBounce(color: Colors.red,size: 75,),
                     Card(
                       elevation: 5,
                       color:Colors.red,
                       shadowColor: Colors.grey[300],
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(30)
                       ),
                       child:IconButton(onPressed: ()async{
                         if (_recorder.isRecording){
                           if (isRecording) {
                             final path = await _recorder.stopRecorder();
                             setState(() {
                               isRecording = false;
                               statusText = "Recording stopped";
                               // Read the recorded audio file
                               List<int> audioBytes = File(path).readAsBytesSync();
                               // Convert the audio data to a Base64 string
                               base64String = base64Encode(audioBytes);

                               // Print the Base64 string
                               print("Base64 String: $base64String");
                             });
                           }
                           setState((){
                             statusText = "Recording pause";
                           });

                         }else{
                           startRecording();
                           setState((){
                             statusText = "Recording...";
                           });
                         }
                       }, icon:Icon(_recorder.isRecording?Icons.mic:Icons.pause,color: Colors.white,)),
                     ),
                   ],
                 ),
                 Card(
                      elevation: 5,
                      color:Color(0xFF00887A),
                      shadowColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child:isAudioSend?IconButton(onPressed: (){
                        statusText = '';
                        SendMessageAudio(
                            payload: {
                              "message_type":"audio",
                              "message":{
                                "audio":"${base64String}"
                              },
                              "sender_id":widget.sender,
                              "receiver_id":widget.receiver_id,
                            }
                        );
                        setState(() {
                          isAudioSend = false;
                        });
                      },icon:Icon(Icons.send,color: Colors.white,)):CircularProgressIndicator(color: Colors.white,)
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
