import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:note_app/edit_note_screen.dart';

import 'db.dart';
import 'note.dart';

enum DisplayType {
  list,
  grid,
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Note'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({this.title});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Db db;
  bool isExpand = false;
  AnimationController animationController;
  Animation<double> animationIcon;
  List<Note> notes = [];
  DisplayType displayType = DisplayType.list;
  List<Color> colors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.redAccent
  ];
  Map<Color, String> colorMap = {
    Colors.blueAccent: 'Blue',
    Colors.greenAccent: 'Green',
    Colors.orangeAccent: 'Orange',
    Colors.redAccent: 'Red'
  };
  Color selectedColor;

  String getDateString(
      {@required String dateFormat, @required DateTime dateTime}) {
    initializeDateFormatting();
    return DateFormat(dateFormat).format(dateTime);
  }

  Widget buildAddButton() {
    return RotationTransition(
      turns: animationIcon,
      child: FloatingActionButton(
        onPressed: () {
          expandButton();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildColorDot(Color color) {
    return FloatingActionButton(
      heroTag: color.toString(),
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () async {
        var shouldUpdateScreen = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditNoteScreen(
                  color: color,
                  editType: EditType.insert,
                ),
              ),
            ) ??
            false;
        if (shouldUpdateScreen) {
          updateScreen();
        }
      },
      child: Container(
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }

  void expandButton() {
    setState(() {
      if (isExpand) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
      isExpand = !isExpand;
    });
  }

  void toEditNote(Note note) async {
    var shouldUpdateScreen = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditNoteScreen(
              color: Color(note.color),
              editType: EditType.update,
              note: note,
            ),
          ),
        ) ??
        false;
    if (shouldUpdateScreen) {
      updateScreen();
    }
  }

  void pressedMore(Note note) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return Container(
            height: 160,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      toEditNote(note);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.create,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Edit',
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FlatButton(
                    onPressed: () async {
                      await db.deleteNote(note);
                      updateScreen();
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buildList() {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                var note = notes[index];
                return GestureDetector(
                  onTap: () {
                    toEditNote(note);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Color(note.color),
                          width: 5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                note.content,
                                style: TextStyle(fontSize: 25),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Update time: ${getDateString(dateFormat: 'yyyy/MM/dd HH:mm', dateTime: DateTime.parse(note.date))}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_horiz),
                          onPressed: () {
                            pressedMore(note);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  Widget buildGrid() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 2,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];
              return GestureDetector(
                onTap: () {
                  toEditNote(note);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color(note.color),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Text(note.content),
                            ),
                            GestureDetector(
                              onTap: () {
                                pressedMore(note);
                              },
                              child: Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Update time: ${getDateString(dateFormat: 'yyyy/MM/dd HH:mm', dateTime: DateTime.parse(note.date))}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                  child: Container(
                      color: Colors.blue,
                      child: FlatButton(
                        child: Icon(
                          Icons.list,
                          color: displayType == DisplayType.list
                              ? Colors.black
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            displayType = DisplayType.list;
                          });
                        },
                      ))),
              Expanded(
                  child: Container(
                      color: Colors.blue,
                      child: FlatButton(
                        child: Icon(
                          Icons.grid_on,
                          color: displayType == DisplayType.grid
                              ? Colors.black
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            displayType = DisplayType.grid;
                          });
                        },
                      ))),
            ],
          ),
          displayType == DisplayType.list ? buildList() : buildGrid(),
        ],
      ),
    );
  }

  Widget buildDrawerHeader() {
    return DrawerHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Note',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'This is a practice note app made by Tung.',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    );
  }

  Widget buildDrawerTile(Color color) {
    if (color == null) {
      return ListTile(
        leading: Icon(Icons.color_lens),
        title: Text('All colors'),
        onTap: () {
          selectedColor = null;
          updateScreen();
          Navigator.of(context).pop();
        },
      );
    }

    return ListTile(
      leading: Container(
        height: 20,
        width: 20,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
      title: Text(colorMap[color]),
      onTap: () {
        selectedColor = color;
        updateScreen();
        Navigator.of(context).pop();
      },
    );
  }

  void updateScreen() {
    db.queryNotes().then((value) {
      setState(() {
        if (selectedColor != null) {
          notes = value
              .where((element) => element.color == selectedColor.value)
              .toList();
        } else {
          notes = value;
        }
      });
    });
  }

  @override
  void initState() {
    db = Db();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animationIcon =
        Tween<double>(begin: 0, end: 0.25).animate(animationController);
    updateScreen();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: colors.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return buildDrawerHeader();
            } else if (index == 1) {
              return buildDrawerTile(null);
            } else {
              return buildDrawerTile(colors[index - 2]);
            }
          },
        ),
      ),
      body: buildBody(),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            isExpand ? buildColorDot(colors[0]) : Container(),
            isExpand ? buildColorDot(colors[1]) : Container(),
            isExpand ? buildColorDot(colors[2]) : Container(),
            isExpand ? buildColorDot(colors[3]) : Container(),
            buildAddButton(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
