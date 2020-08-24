import 'package:flutter/material.dart';
import 'package:note_app/note.dart';
import 'package:uuid/uuid.dart';

import 'db.dart';

enum EditType {
  insert, update,
}

class EditNoteScreen extends StatefulWidget {
  final Color color;
  final EditType editType;
  final Note note;

  EditNoteScreen({this.color, this.editType, this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  Db db;
  TextEditingController textEditingController;

  Widget buildTextField() {
    return Material(
      child: Container(
        color: widget.color,
        child: SingleChildScrollView(
          child: TextField(
            style: TextStyle(fontSize: 25),
            controller: textEditingController,
            keyboardType: TextInputType.multiline,
            maxLines: 999,
            autofocus: true,
            scrollPadding: EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }

  void onPressSave() async {
    switch (widget.editType) {
      case EditType.insert:
        var date = DateTime.now().toIso8601String();
        var content = textEditingController.text;
        var note = Note(content: content, date: date, color: widget.color.value, id: Uuid().v1());
        await db.insertNote(note);
        break;
      case EditType.update:
        var note = widget.note;
        var date = DateTime.now().toIso8601String();
        var content = textEditingController.text;
        var newNote = Note(content: content, date: date, color: note.color, id: note.id);
        await db.updateNote(newNote);
        break;
    }

    Navigator.pop(context, true);
  }

  @override
  void initState() {
    textEditingController = TextEditingController();
    textEditingController.text = widget.note == null ? '' : widget.note.content;
    db = Db();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text('Edit note'),
        backgroundColor: widget.color,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              onPressSave();
            },
          ),
        ],
      ),
      body: Hero(
        tag: widget.color.toString(),
        child: Container(
          padding: EdgeInsets.all(20),
          color: widget.color,
          child: buildTextField(),
        ),
      ),
    );
  }
}
