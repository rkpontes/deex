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

## Widget responsible for rebuilding Widgets

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

## The Controller with reactive state
The `Controller` extends `DeexStore` and contains the reactive state, using the `.obs` extension to make the variables observable.

```dart
class Controller extends DeexStore {
  var count = 0.obs;
  void increment() => count++;
}
```

## License
This project is licensed under the MIT license - see the LICENSE file for more details.

## Contribution
Contributions are welcome! Please open an [issue](https://github.com/rkpontes/deex/issues) or submit a [pull request](https://github.com/rkpontes/deex/pulls).

## Author
Maintained by [Raphael Pontes](https://www.linkedin.com/in/raphaelkennedy/).

Did I help you? [Buy me a coffee](https://buymeacoffee.com/raphaelpontes).