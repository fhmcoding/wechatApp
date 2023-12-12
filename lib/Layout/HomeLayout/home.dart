import 'package:flutter/material.dart';

import '../../modules/Pages/contact.dart';

class HomeScreen extends StatefulWidget {
  final List contacts;
  final name;
   HomeScreen({Key key,this.contacts, this.name}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedItem = 'اختر رقم هاتف';
  List<String> contacts = [];
  void getContacts(){
    contacts.add('اختر رقم هاتف');
    widget.contacts.forEach((element){
      contacts.add(element['phone_number']);
    });
  }
  var user;
  void getContact({phone_number}){
  user = widget.contacts.where((element) => element['phone_number']==phone_number).first;
  }
  @override
  void initState() {
    getContacts();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    print(contacts);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Text('Wechats مرحبًا بكم في ',style: TextStyle(fontSize: 29,fontWeight:FontWeight.w600,color: Colors.teal),),
            SizedBox(height: 50,),
            Image.asset('assets/bg.png',color: Colors.greenAccent[700],height: 340,width: 340,),
            SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.only(left: 50,right: 50),
              child: Text('الرجاء تحديد الرقم الذي تريد الدردشة بيه',style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),textAlign: TextAlign.center,),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 35,right: 35,),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child:
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16,),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color:Colors.greenAccent[700]),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedItem,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.grey[600],),
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedItem = newValue;
                          getContact(phone_number: newValue);
                        });
                      },
                      items:contacts.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                             Icon(Icons.phone,color: Colors.green),
                              SizedBox(width: 10,),
                              Text(value,textDirection: TextDirection.ltr),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
           InkWell(
             onTap: (){
               if(_selectedItem=='اختر رقم هاتف'){
                print(_selectedItem);
               }else{
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Contact(user:user,name:widget.name)));
               }

             },
             child: Container(
               width: MediaQuery.of(context).size.width-110,
               height: 50,
               child: Card(
                margin: EdgeInsets.all(0),
                 elevation: 8,
                 color: Colors.greenAccent[700],
                 child: Center(
                     child: Text(
                         'استمر',
                       style: TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.w600,
                         fontSize: 17
                       ),
                     )),
               ),
             ),
           )
          ],
        ),
      ),
    );
  }
}
