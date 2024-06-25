# Deex

Deex is a state management library for Flutter, based on GetX but focused exclusively on state management. This README provides an overview of how to use Deex in a Flutter application.

## Installation
Add Deex to your pubspec.yaml file:

```yaml
dependencies:
  deex: # latest
```

Then run:

``` shell
flutter pub get
```

## Usage

```dart
import 'package:deex/deex.dart';
```

## Rebuilding Widgets

### Widget

The `Deex` widget makes the UI reactive to changes in the controller state, rebuilding the UI whenever the observed state changes.

```dart
Deex(
  () => Text('${controller.count.value}'),
),
```

The widget rebuilds itself every time the action is executed:
```dart
onPressed: controller.increment,
```

### Controller
The `Controller` extends `DeexStore` and contains the reactive state, using the `.obs` extension to make the variables observable.

```dart
class Controller extends DeexStore {
  var count = 0.obs;
  void increment() => count++;
}
```

### Similar to Deex, but manages a local state.
Pass the initial data in constructor.
Useful for simple local states, like toggles, visibility, themes, button states, etc.

Sample:
```dart
DeexValue((data) => Switch(
    value: data.value,
    onChanged: (flag) => data.value = flag,
  ),
  false.obs,
),
```

## Rebuilding Widgets with State

### Widget

In this example, the `Deex` widget rebuilds the button each time the state changes. The button text is based on the current state of the `RequestController`.

```dart
Deex(() {
  return ElevatedButton(
    onPressed: stateController.sendRequest,
    child: Text(
      stateController.state.value.message,
    ),
  );
}),
```

### Controller

The `RequestController` manages the state of the request. It sets the initial state, changes the state to "loading" when sending a request, and after a simulated delay, changes the state to "completed" with the data received.

```dart
class RequestController extends DeexStore {
  final Rx<RequestState> state = Rx<RequestState>(InitialRequestState());

  void sendRequest() {
    _setLoadingState();
    _simulateRequest()
        .then((data) => _setCompletedState(data))
        .catchError((error) => _setErrorState(error));
  }

  void _setLoadingState() {
    state.value = LoadingRequestState();
  }

  void _setCompletedState(dynamic data) {
    state.value = CompletedRequestState(data);
  }

  void _setErrorState(dynamic error) {
    state.value = ErrorRequestState(error.toString());
  }

  Future<dynamic> _simulateRequest() {
    return Future.delayed(const Duration(seconds: 2), () {
      return {'data': 'Hello World!'};
    });
  }
}
```

### States

States represent different phases of a request. Each state has a message that describes its status.

```dart 
abstract class RequestState {
  final String message;
  RequestState(this.message);
}

class InitialRequestState extends RequestState {
  InitialRequestState() : super('Request State');
}

class LoadingRequestState extends RequestState {
  LoadingRequestState() : super('Loading...');
}

class CompletedRequestState extends RequestState {
  final dynamic data;
  CompletedRequestState(this.data) : super('Request completed');
}

class ErrorRequestState extends RequestState {
  ErrorRequestState(String message) : super('Error: $message');
}
```

This approach allows for efficient state management, ensuring that the user interface always reflects the most recent state of the application.

## DeexConsumer

The `DeexConsumer` is a Flutter widget designed to efficiently manage and respond to state changes in a DeexStore. It listens to updates from the store and rebuilds its UI based on the new state. This widget providing a convenient way to separate business logic from the UI.


### Advantages of Using DeexConsumer

1. Separation of Concerns: DeexConsumer helps in maintaining a clear separation between the business logic and the UI. This makes the code more maintainable and easier to understand.

2. Reactive Updates: By listening to changes in the DeexStore, DeexConsumer ensures that the UI is always up-to-date with the latest state, providing a reactive programming model.

3. Selective Listening: DeexConsumer allows you to specify which parts of the state to listen to using the listenIds parameter. This can help in optimizing performance by reducing unnecessary rebuilds.

4. Easy State Management: It simplifies state management in Flutter applications by providing a straightforward and consistent way to handle state changes and update the UI accordingly.

### Usage Example

Here's an example of how you might use the `DeexConsumer` in your application:

```dart
import 'package:flutter/material.dart';
import 'package:deex/deex.dart';

class CounterStore extends DeexStore {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    update();
  }
}

class CounterPage extends StatelessWidget {
  final CounterStore store = CounterStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: DeexConsumer<CounterStore>(
          store: store,
          builder: (context, store) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You have pushed the button this many times:'),
                Text('${store.count}', style: Theme.of(context).textTheme.headline4),
              ],
            );
          },
          listener: (store) {
            print('Store updated: ${store.count}');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: store.increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CounterPage(),
  ));
}
```


## Notifiers

### ListNotifierSingle

The `ListNotifierSingle` is a notifier that allows you to add, remove, and check for individual listeners. It is useful for managing state changes where only a single listener needs to be notified of updates.


```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final ListNotifierSingle _notifier = ListNotifierSingle();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _notifier.refresh();
      },
      child: Text('Refresh'),
    );
  }
}
```

### ListNotifierGroup

The `ListNotifierGroup` is a notifier that supports managing groups of listeners identified by unique IDs. It is useful for scenarios where you need to manage and notify multiple listeners, organized by specific categories or groups.

```dart
class MyGroupWidget extends StatefulWidget {
  @override
  _MyGroupWidgetState createState() => _MyGroupWidgetState();
}

class _MyGroupWidgetState extends State<MyGroupWidget> {
  final ListNotifierGroup _notifier = ListNotifierGroup();

  @override
  void initState() {
    super.initState();
    _notifier.addListenerId('button1', () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _notifier.refreshGroup('button1');
          },
          child: Text('Refresh Button 1'),
        ),
        ElevatedButton(
          onPressed: () {
            _notifier.refreshGroup('button2');
          },
          child: Text('Refresh Button 2'),
        ),
      ],
    );
  }
}
```

## License
This project is licensed under the MIT license - see the LICENSE file for more details.

## Contribution
Contributions are welcome! Please open an [issue](https://github.com/rkpontes/deex/issues) or submit a [pull request](https://github.com/rkpontes/deex/pulls).

## Author
Maintained by [Raphael Pontes](https://www.linkedin.com/in/raphaelkennedy/).

Did I help you? [Buy me a coffee](https://buymeacoffee.com/raphaelpontes).