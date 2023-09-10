import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator()),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: () {
             startDownloadUsingOldIsolateMethodWithErrorHandling();

            }, child: const Text("Start Heavy Process with Isolate")),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Future<String> startDownloadUsingOldIsolateMethodWithErrorHandling() async {
    const String imageDownloadLink = 'this is a link';
    // create the port to receive data from
    final resultPort = ReceivePort();
    // Adding errorsAreFatal makes sure that the main isolates receives a message
    // that something has gone wrong
    try {
      await Isolate.spawn(
        _readAndParseJson,
        [resultPort.sendPort, imageDownloadLink],
        errorsAreFatal: true,
        onExit: resultPort.sendPort,
        onError: resultPort.sendPort,
      );
    } on Object {
      // check if sending the entrypoint to the new isolate failed.
      // If it did, the result port won’t get any message, and needs to be closed
      resultPort.close();
    }

    final response = await resultPort.first;

    if (response == null) {
      // this means the isolate exited without sending any results
      // TODO throw error
      printData('No message');
      return 'No message';
    } else if (response is List) {
      // if the response is a list, this means an uncaught error occurred
      final errorAsString = response[0];
      final stackTraceAsString = response[1];
      // TODO throw error
      printData( 'Uncaught Error');
      return 'Uncaught Error';
    } else {
      printData(response as String);
      return response as String;
    }
  }

  // we create a top-level function that specifically uses the args
// which contain the send port. This send port will actually be used to
// communicate the result back to the main isolate

// This function should have been isolate-agnostic
  static void _readAndParseJson(List<dynamic> args) async {
    SendPort resultPort = args[0];
    String fileLink = args[1];

    String newImageData = fileLink;

  //  await Future.delayed(const Duration(seconds: 2));

    Isolate.exit(resultPort, newImageData);
  }
  void printData(String data){
    if (kDebugMode) {
      print(data);
    }
  }
}
