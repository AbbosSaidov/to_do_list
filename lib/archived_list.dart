import 'package:flutter/material.dart';
import 'package:to_do_list/main.dart';

import 'TodoItem.dart';

class ArchivedPage extends StatefulWidget {
  ArchivedPage({Key? key,
    this.liss
  }) : super(key: key);
  final List<TodoItem>? liss;
  @override
  _ArchivedPageState createState() => new _ArchivedPageState();
}

class _ArchivedPageState extends State<ArchivedPage>{


  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return  Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.amber[900],
        title:  const Text(
         "Archived list" ,
          style: TextStyle(fontSize: 30),
        ),

      ),
      body:ListView.builder(
        itemCount: widget.liss?.length,
        itemBuilder: (context, i) {
          if(widget.liss![i].ifArchive){
            return Padding(
              padding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
                top: 5.0,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.only(top: 5,bottom: 5,left: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                tileColor: Colors.red,
                textColor: Colors.white,
                iconColor: Colors.white,
                // leading:  Icon(Icons.light),
                title:  Text(widget.liss![i].title),
                subtitle:  Text('Time ${widget.liss![i].time.substring(0,16)}\n${widget.liss![i].description}'),
              ),
            );
          }else{
            return Container();
          }

        },
      )
    );
  }

}