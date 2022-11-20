import 'dart:developer';

import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/TodoItem.dart';
import 'package:to_do_list/archived_list.dart';
import 'package:to_do_list/item_page.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'To Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget{
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _SliverAnimatedListSampleState();
}

class _SliverAnimatedListSampleState extends State<MyHomePage>{
  final GlobalKey<SliverAnimatedListState> _listKey =GlobalKey<SliverAnimatedListState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  late ListModel<TodoItem> _list;
  bool loadItems=false;

  late TextEditingController textController;
  final ScrollController _scrollController=ScrollController();
  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }
  @override
  void initState(){
    super.initState();
    textController = TextEditingController();
    getItems();
  }

  Future<void> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds:1),(){
      String? allToDoList;
      if(/**/prefs.containsKey("ItemsKey")){
        //Get all items
        allToDoList =prefs.getString("ItemsKey");
        log("sa="+allToDoList.toString());
        List<TodoItem> initialList=todoItemFromJson(allToDoList!);
        List<TodoItem> clearlist=[];
        for(int i=0;i<initialList.length;i++){
          if(!initialList[i].ifArchive && !initialList[i].ifDone){
            clearlist.add(initialList[i]) ;
          }
        }

        _list = ListModel<TodoItem>(
          listKey: _listKey,
          initialItems: clearlist,
          removedItemBuilder: _buildRemovedItem,
        );
      //  listOfItems=todoItemFromJson(allToDoList!);
      }else{
        //It first time so we adding 15 ToDoExamples
        List<TodoItem> listOfItems=[];
        for(int i=0;i<15;i++){
          listOfItems.add(
              TodoItem(
                  id: i,
                  title: "Title $i",
                  description: "Description $i",
                  ifDone: false,
                  ifArchive: (i==14 || i==13 ) ? true :false,
                  time: DateTime.now().add(Duration(days: i)).toString()));
        }
        prefs.setString("ItemsKey",todoItemToJson(listOfItems));
        listOfItems.removeAt(14);listOfItems.removeAt(13);
        _list = ListModel<TodoItem>(
          listKey: _listKey,
          initialItems: listOfItems,
          removedItemBuilder: _buildRemovedItem,
        );
      }
      loadItems=true;
      setState((){});
    });
    await Future.delayed(const Duration(milliseconds:30), () {});
    _scrollController.jumpTo( 60,);
  }
  // Used to build list items that haven't been removed.
  Widget _buildItem(BuildContext context, int index, Animation<double> animation){
    return CardItem(
      animation: animation,
      item: _list[index],
      onTap: () async {
        Navigator.of(context).push(_animationRoute(index: index ));
      },
      onDelete:()async{
        print("index="+index.toString());
        final prefs = await SharedPreferences.getInstance();
        String?  allToDoList =prefs.getString("ItemsKey");
        List<TodoItem> initialList=todoItemFromJson(allToDoList!);
        for(int i=0;i<initialList.length;i++){
          if(initialList[i].id.toString()==_list[index].id.toString()){
            print("index="+index.toString());
            initialList[i].ifArchive=true;break;
          }
        }
        prefs.setString("ItemsKey",todoItemToJson(initialList));
        _remove(indexOfItem:initialList[index],index: index );
      },
      onCheck:()async{
        final prefs = await SharedPreferences.getInstance();
        String?  allToDoList =prefs.getString("ItemsKey");
        List<TodoItem> initialList=todoItemFromJson(allToDoList!);
        for(int i=0;i<initialList.length;i++){
          if(initialList[i].id.toString()==_list[index].id.toString()){
            initialList[i].ifDone=true;break;
          }
        }
        prefs.setString("ItemsKey",todoItemToJson(initialList));
        _remove(indexOfItem:initialList[index],index: index );
      },
    );
  }
  Route _animationRoute({int? index,List<TodoItem>? lists,bool? ifArchive=false})  {
    int idSample=0;
    if(lists!=null){
      idSample =lists.length;
      //make uniqueID
      y: for(int i=0;i<30;i++){
        y1:  for(int t=0;t<lists.length;t++){
          if(lists[t].id==lists.length+i ){
            break y1;
          }else if(lists.length-1==t){
            idSample=lists.length+i;
            break y;
          }
        }
      }
    }


    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      !(ifArchive??false) ?ItemPage(
            insert: _insert,
            indexl: index,
            remove: _remove,
            change: _changeList,
            item:index!=null? _list._items[index]:TodoItem(id: idSample, title: "", description: "", ifDone: false, ifArchive: false, time: DateTime.now().toString())
          ):ArchivedPage(liss:lists ,),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1, 0);
        const end = Offset(0, 0);
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  // Used to build an item after it has been removed from the list. This
  // method is needed because a removed item remains visible until its
  // animation has completed (even though it's gone as far this ListModel is
  // concerned). The widget will be used by the
  // [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
      int item, TodoItem itemTodo, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: itemTodo,
    );
  }

  // Insert the "next item" into the list model.
  void _insert(itemt,index){
    _list.insert(index, itemt);
  }

  // Remove the selected item from the list model.
  void _remove({int? index,TodoItem? indexOfItem,}) {
      if(indexOfItem==null){
        _list.removeAt(index!,indexOfItem!,);
        setState(() {});
        context.showFlashBar(
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black,
          content: const Text('You have deleted task',
            style:TextStyle(color: Colors.white),),
        );
      }else{
        try{
          _list.removeAt(index!,indexOfItem,);
        }catch(e,s){
          print("error_remove=$e == $s");
        }
      }
  }
  void _changeList(listOfItems){
    _list.changeList(listOfItems);
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        key: _scaffoldKey,
        body:loadItems? CustomScrollView(
          controller: _scrollController ,
          slivers: <Widget>[
           SliverAppBar(
             actions: [
               IconButton(
                 icon: const Icon(Icons.archive_outlined),
                 onPressed:() async {

                   //  _insert(6);
                   final prefs = await SharedPreferences.getInstance();
                   String?  allToDoList =prefs.getString("ItemsKey");
                   List<TodoItem> initialList=todoItemFromJson(allToDoList!);
                   Navigator.of(context).push(_animationRoute(lists: initialList,ifArchive: true));
                 } ,
                 tooltip: 'Insert a new item.',
                 iconSize: 32,
               ),
             ],
             title: Text(
               widget.title,
               style: TextStyle(fontSize: 30),
             ),
             expandedHeight: 120,
             centerTitle: true,
             floating: true,
             pinned: true,
             backgroundColor: Colors.amber[900],
             leading: IconButton(
               icon: const Icon(Icons.add_circle),
               onPressed:() async {
               //  _insert(6);
                 final prefs = await SharedPreferences.getInstance();
                 String?  allToDoList =prefs.getString("ItemsKey");
                 List<TodoItem> initialList=todoItemFromJson(allToDoList!);
                 Navigator.of(context).push(_animationRoute(lists: initialList));
                 } ,
               tooltip: 'Insert a new item.',
               iconSize: 32,
             ),
             flexibleSpace: FlexibleSpaceBar(
               collapseMode: CollapseMode.pin,
               centerTitle:true,
               background:Column(
                 children:[
                   const SizedBox(height: 60,),
                   Padding(
                     padding: const EdgeInsets.all(16.0),
                     child:  CupertinoSearchTextField(
                       onChanged: (value) async {
                         final prefs = await SharedPreferences.getInstance();
                         String?  allToDoList =prefs.getString("ItemsKey");
                         List<TodoItem> initialList=todoItemFromJson(allToDoList!);

                         List<TodoItem> newList=[];

                         for(int i=0;i<initialList.length;i++){
                           if(!initialList[i].ifDone && !initialList[i].ifArchive){
                             if(initialList[i].title.toLowerCase().contains(value.toString().toLowerCase())){

                               newList.add(initialList[i]);
                             }else if(value.isEmpty){
                               newList.add(initialList[i]);
                             }
                           }
                         }
                         if(newList.length!=_list.length){
                           for(int t=initialList.length-1;t>=0;t--){
                             print("t="+t.toString());
                             _remove(indexOfItem:initialList[t],index:t );
                           }

                           //insert what found
                           for(int t=0;t<initialList.length;t++){
                             if(newList.contains(initialList[t])){
                               _insert(initialList[t],_list.length);
                             }
                           }
                         }
                         //remove everything


                      //   _selectedItem=null;
                         setState((){});
                       },
                       backgroundColor: Colors.black.withOpacity(0.1),
                       prefixIcon: Icon(Icons.search,color: Colors.white.withOpacity(1),size: 23,),
                       suffixIcon: Icon(Icons.clear,color: Colors.white.withOpacity(1),size: 23,),
                       style: const TextStyle(color: Colors.white,fontSize: 21),
                       placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.6),fontSize: 21),
                       controller: textController,
                       placeholder: 'Search',
                     )
                 )
                 ] ,
               ),
             ),
             ),
            _list.length!=0? SliverAnimatedList(
              key: _listKey,
              initialItemCount: _list.length,
              itemBuilder: _buildItem,
            ):const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 2.0,
                  right: 2.0,
                  top: 2.0,
                ),
                child: SizedBox(
                  height: 80.0,
                  child: Center(
                    child: Text(
                      'Not found',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ):Center(child:CircularProgressIndicator() ,),
      ),
    );
  }
}

typedef RemovedItemBuilder = Widget Function(int item,TodoItem itemTodo, BuildContext context, Animation<double> animation);

class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<SliverAnimatedListState> listKey;
  final RemovedItemBuilder removedItemBuilder;
  List<E> _items;

  SliverAnimatedListState get _animatedList => listKey.currentState!;

  void insert(int index, E item) {
    _items.add(item);
    try{
      _animatedList.insertItem(_items.length-1,duration: Duration(milliseconds: 30));
    }catch(e,s){
      print("eror insert $e $s");
    }
  }
  void changeList(E){
    _items=E;
    _animatedList.setState((){});
  }

  E removeAt(int index,TodoItem indextTodo){
   // print("leng="+_items.length.toString()+" index="+index.toString());
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
        index,
            (BuildContext context, Animation<double> animation) =>
            removedItemBuilder(index,indextTodo, context, animation),
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    this.onTap,
    this.onDelete,
    this.onCheck,
    required this.animation,
    required this.item,
  });

  final Animation<double> animation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCheck;
  final TodoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 5.0,
        right: 5.0,
        top: 5.0,
      ),
      child: SizeTransition(
        sizeFactor: animation,
        child: GestureDetector(
          onTap: onTap,
          child: ListTile(
            contentPadding: EdgeInsets.only(top: 5,bottom: 5,left: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            tileColor: Colors.green,
            textColor: Colors.white,
            iconColor: Colors.white,
           // leading:  Icon(Icons.light),
            title:  Text(item.title),
            subtitle:  Text('Time ${item.time.substring(0,16)}\n${item.description}'),
            trailing:Container(
              width: 100,
              child:Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: onCheck,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed:onDelete,
                  ),
                ],
              ) ,
            )  ,
          ),
        ),
      ),
    );
  }
}
