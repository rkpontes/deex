import 'package:deex/state_manager/rx_flutter/rx_widget.dart';
import 'package:example/controller.dart';
import 'package:example/request_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final controller = Controller();
  final stateController = RequestController();

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Deex(() => Text(controller.title)),
        actions: [
          ElevatedButton(
            onPressed: controller.changeTitle,
            child: const Text("Change title"),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _increment(context),
            const SizedBox(height: 40),
            _buttonWithState(),
          ],
        ),
      ),
    );
  }

  Widget _buttonWithState() {
    return Deex(() {
      return ElevatedButton(
        onPressed: stateController.sendRequest,
        child: Text(
          stateController.state.value.message,
        ),
      );
    });
  }

  Widget _increment(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('You have pushed the button this many times:'),
          Deex(
            () => Text(
              '${controller.count.value}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: controller.increment,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
