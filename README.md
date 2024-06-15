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

## License
This project is licensed under the MIT license - see the LICENSE file for more details.

## Contribution
Contributions are welcome! Please open an [issue](https://github.com/rkpontes/deex/issues) or submit a [pull request](https://github.com/rkpontes/deex/pulls).

## Author
Maintained by [Raphael Pontes](https://www.linkedin.com/in/raphaelkennedy/).

Did I help you? [Buy me a coffee](https://buymeacoffee.com/raphaelpontes).