import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:isolates/user_data_model.dart';
import 'package:isolates/widgets/animating_container.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Large JSON Example')),
        body: const JsonLoader(),
      ),
    );
  }
}

class JsonLoader extends StatefulWidget {
  const JsonLoader({super.key});

  @override
  _JsonLoaderState createState() => _JsonLoaderState();
}

class _JsonLoaderState extends State<JsonLoader> {
  bool isLoading = true;
  List<UserDataModel> userData = [];

  Future<String> get getJsonAsString async => rootBundle.loadString('assets/large_data.json');

  Future<void> _loadJson() async {
    setState(() {
      isLoading = true;
      userData.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final jsonString = await getJsonAsString;
      final jsonData = await _parseJsonInIsolate(jsonString);

      jsonData.forEach((element) {
        userData.add(UserDataModel.fromJson(element));
      });

      setState(() {
        isLoading = false;
      });
    });
  }

  static Future<List<dynamic>> _parseJsonInIsolate(String jsonString) async {
    final p = ReceivePort();
    await Isolate.spawn(_isolateEntry, [p.sendPort, jsonString]);
    return await p.first;
  }

  static void _isolateEntry(List<dynamic> args) {
    final sendPort = args[0] as SendPort;
    final jsonString = args[1] as String;
    final jsonData = jsonDecode(jsonString);
    sendPort.send(jsonData);
  }

  Future<void> _loadDataWithoutIsolate() async {
    setState(() {
      isLoading = true;
      userData.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final jsonString = await getJsonAsString;
      jsonDecode(jsonString).forEach((element) {
        userData.add(UserDataModel.fromJson(element));
      });

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              _loadJson();
            },
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              _loadDataWithoutIsolate();
            },
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Center(child: AnimatingContainer()),
          ListView.builder(
            itemCount: userData.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text(userData[index].id.toString()),
                title: Text(userData[index].title),
                subtitle: Text(userData[index].body),
              );
            },
          ),
        ],
      ),
    );
  }
}
