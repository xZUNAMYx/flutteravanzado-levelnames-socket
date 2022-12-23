import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:levels_aplication/models/models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Level> levels = [
    Level(id: '1', name: 'A1', quantity: 175),
    Level(id: '2', name: 'A2', quantity: 75),
    Level(id: '3', name: 'B1', quantity: 25),
    Level(id: '4', name: 'B2', quantity: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Niveles de inglés'),
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (BuildContext context, int index) {
          return _levelTile(levels[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewLevel,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _levelTile(Level level) {
    return Dismissible(
      key: Key(level.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        print('direction: $direction');
        print('id: ${level.id}');
        // TODO: llamar el corrado en el server
      },
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Level'),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(level.name.substring(0, 2)),
        ),
        title: Text(level.name),
        trailing: Text('${level.quantity}'),
        onTap: () {
          print(level.name);
        },
      ),
    );
  }

  addNewLevel() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New level name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addLevelToList(textController.text),
                child: const Text('Add'),
              )
            ],
          );
        },
      );
    }

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('New Level name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => addLevelToList(textController.text),
                child: const Text('Add'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => addLevelToList(textController.text),
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );
    }
  }

  void addLevelToList(String name) {
    print(name);
    if (name.length > 1) {
      //Podemos agregar
      levels.add(
        Level(id: DateTime.now().toString(), name: name, quantity: 0),
      );
      setState(() {});
    }

    Navigator.pop(context);
  }
}
