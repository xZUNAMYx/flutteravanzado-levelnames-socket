import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:levels_aplication/models/models.dart';
import 'package:levels_aplication/services/services.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Level> levels = [
    /* Level(id: '1', name: 'A1', quantity: 175),
    Level(id: '2', name: 'A2', quantity: 75),
    Level(id: '3', name: 'B1', quantity: 25),
    Level(id: '4', name: 'B2', quantity: 5), */
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-levels', _handleActiveLevel);
    super.initState();
  }

  _handleActiveLevel(dynamic payload) {
    //print(payload);
    levels = (payload as List).map((level) => Level.fromMap(level)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-levels');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cantidad por cada nivel de inglés',
          overflow: TextOverflow.visible,
        ),
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? const Icon(Icons.check_box)
                : const Icon(Icons.offline_bolt, color: Colors.red),
            //TODO:terniario
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: levels.length,
              itemBuilder: (BuildContext context, int index) {
                return _levelTile(levels[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewLevel,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _levelTile(Level level) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(level.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        // print('id: ${level.id}');
        // emitir: delete-level
        // {'id': level.id}
        socketService.socket.emit('delete-level', {'id': level.id});
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
          socketService.socket.emit('vote-level', {'id': level.id});
        },
      ),
    );
  }

  addNewLevel() {
    final textController = TextEditingController();

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
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      socketService.socket.emit('add-level', {'name': name});
    }

    Navigator.pop(context);
  }

  // Mostrar Gráfica
  Widget _showGraph() {
    Map<String, double> dataMap = {}; //Map();
    /* "Flutter": 5,
      "React": 3,
      "Xamarin": 2,
      "Ionic": 2, */
    levels.forEach((level) {
      dataMap.putIfAbsent(level.name, () => level.quantity.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue,
      const Color.fromARGB(255, 50, 94, 131),
      Colors.green,
      const Color.fromARGB(255, 19, 158, 26),
      Colors.yellow,
      Colors.yellowAccent,
    ];

    return Container(
      //padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap.isEmpty ? {'No hay datos': 0} : dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 22,
        chartRadius: MediaQuery.of(context).size.width / 1.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.disc,
        ringStrokeWidth: 32,
        centerText: "CANTIDAD",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          //legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      ),
    );
  }
}
