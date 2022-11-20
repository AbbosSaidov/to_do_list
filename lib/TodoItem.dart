import 'dart:convert';


List<TodoItem> todoItemFromJson(String str) => List<TodoItem>.from(json.decode(str).map((x) => TodoItem.fromJson(x)));

String todoItemToJson(List<TodoItem> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.ifDone,
    required this.ifArchive,
    required this.time,
  });

  int id;
  String title;
  String description;
  bool ifDone;
  bool ifArchive;
  String time;

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    ifDone: json["ifDone"],
    ifArchive: json["ifArchive"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "ifDone": ifDone,
    "ifArchive": ifArchive,
    "time": time,
  };
}
