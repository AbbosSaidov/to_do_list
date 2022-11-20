import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/TodoItem.dart';

class ItemPage extends StatefulWidget {
  ItemPage({Key? key,
    required this.item,
    required this.remove,
    required this.insert,
    required this.change,
      this.indexl,
  }) : super(key: key);

  final TodoItem item;
  int? indexl;
  var remove;
  var change;
  var insert;

  @override
  _ItemPageState createState() => new _ItemPageState();
}

class _ItemPageState extends State<ItemPage>{

  late TextEditingController titleContoller;
  late TextEditingController desctiptionContoller;

  @override
  void initState(){
    super.initState();
    titleContoller = TextEditingController.fromValue(TextEditingValue(text: widget.item.title));
    desctiptionContoller = TextEditingController.fromValue(TextEditingValue(text: widget.item.description));
  }
  @override
  Widget build(BuildContext context){
    return  Scaffold(
      appBar:AppBar(
        leading:  IconButton(onPressed: (){
          Navigator.pop(context);
        },
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[900],
        title:  Text(widget.item.title,style: TextStyle(fontSize: 30),),
        actions: [
          IconButton(
            onPressed:()async{
            final prefs = await SharedPreferences.getInstance();
            String?  allToDoList =prefs.getString("ItemsKey");
            List<TodoItem> initialList=todoItemFromJson(allToDoList!);
            List<TodoItem> removedList=[];
            Navigator.pop(context);
            if(widget.indexl!=null){
              for(int i=0;i<initialList.length;i++){
                if(initialList[i].id.toString()==widget.item.id.toString()){
                  initialList[i].title=titleContoller.text;
                  initialList[i].description=desctiptionContoller.text;
                  initialList[i].time=widget.item.time;
                  break;
                }
              }
              prefs.setString("ItemsKey",todoItemToJson(initialList));
              for(int t=0;t<initialList.length;t++){
                if(!initialList[t].ifDone && !initialList[t].ifArchive){
                  removedList.add(initialList[t]);
                }
              }
              widget.change(removedList);
            }else{
              widget.item.title=titleContoller.text;
              widget.item.description=desctiptionContoller.text;
              widget.item.time=widget.item.time;
              initialList.add(widget.item);
              prefs.setString("ItemsKey",todoItemToJson(initialList));
              widget.insert(widget.item,initialList.length);
            }

          },
          icon: Icon(Icons.check),
          iconSize: 30,
        ),
         widget.indexl!=null? IconButton(
           onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            String?  allToDoList =prefs.getString("ItemsKey");
            List<TodoItem> initialList=todoItemFromJson(allToDoList!);
            for(int i=0;i<initialList.length;i++){
              if(initialList[i].id.toString()==widget.item.id.toString()){
                initialList[i].ifArchive=true;break;
              }
            }
            prefs.setString("ItemsKey",todoItemToJson(initialList));
            widget.remove(indexOfItem:widget.item,index: widget.indexl );
            Navigator.pop(context);
          },
            icon: Icon(Icons.delete_outline),
            iconSize: 30,
          ):Container(),
        ],
      ),
      body:Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Container(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(10),
              child:  CupertinoTextField.borderless(
                controller: titleContoller,
                padding: EdgeInsets.only(left: 65, top: 10, right: 6, bottom: 10),
                prefix: Text('Title'),
              ),
            ),
            Container(
              height: 25,
            ),

            Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(10),
              child:  CupertinoTextField.borderless(
                controller: desctiptionContoller,
                padding: EdgeInsets.only(left: 25, top: 10, right: 6, bottom: 10),
                prefix: Text('Description'),
              ),
            ),
            Container(
              height: 25,
            ),
            InkWell (
             child:IgnorePointer(
               child: Container(
                 decoration: BoxDecoration(
                     color: Colors.black.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(10)),
                 padding: const EdgeInsets.all(10),
                 child:  CupertinoTextField.borderless(
                   controller: TextEditingController.fromValue(TextEditingValue(text: widget.item.time.substring(0,16))),
                   padding: EdgeInsets.only(left: 65, top: 10, right: 6, bottom: 10),
                   prefix: Text('Date'),
                 ),
               ),
             ) ,
             onTap: (){
               _showDialog(
                 CupertinoDatePicker(
                   initialDateTime: DateTime.now(),
                   mode: CupertinoDatePickerMode.dateAndTime,
                   use24hFormat: true,
                   // This is called when the user changes the date.
                   onDateTimeChanged: (DateTime newDate) {
                     widget.item.time="${newDate.year.toString()}-${newDate.month.toString().padLeft(2,'0')}-"
                         "${newDate.day.toString().padLeft(2,'0')} ${newDate.hour.toString().padLeft(2,'0')}-"
                         "${newDate.minute.toString().padLeft(2,'0')}";
                     setState((){});
                   },
                 ),
               );
             },
           ) ,
          ],)
        ),
    );
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
          child: SafeArea(
            top: false,
            child: child,
          ),
        ));
  }
}