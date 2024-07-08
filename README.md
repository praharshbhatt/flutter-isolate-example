# Flutter Isolate Example

This repository demonstrates how to use isolates in a Flutter application to offload heavy computational tasks and keep the UI responsive. The example shows how to parse a large JSON file both with and without isolates.

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Git: [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Installation

1. Clone the repository:

    ```sh
    git clone https://github.com/praharshbhatt/flutter-isolate-example.git
    ```

2. Navigate to the project directory:

    ```sh
    cd flutter-isolate-example
    ```

3. Get the dependencies:

    ```sh
    flutter pub get
    ```

### Running the App

1. Ensure you have a device connected or an emulator running.
2. Run the app:

    ```sh
    flutter run
    ```

## Usage

The app provides two buttons to load a large JSON file:

- **Green Button:** Parses the JSON file using an isolate to keep the UI responsive.
- **Red Button:** Parses the JSON file on the main thread, which can cause the UI to lag.

### Code Overview

The main logic is implemented in the `JsonLoader` widget:

```dart
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
```

### Model Class

The `UserDataModel` class represents the structure of the JSON data:

```dart
class UserDataModel {
  final int userId, id;

  final String title, body;

  UserDataModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }
}
```

### Assets

Ensure you have a large JSON file in your `assets` directory. Update `pubspec.yaml` to include the assets:

```yaml
flutter:
  assets:
    - assets/large_data.json
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
