import 'dart:async';

import 'package:flutter/widgets.dart';

import 'list_notifier.dart';

/// Defines a callback that takes a value of generic type T and returns nothing
typedef ValueBuilderUpdateCallback<T> = void Function(T snapshot);

/// Defines a callback that takes a value of generic type T and an updater, and returns a Widget
typedef ValueBuilderBuilder<T> = Widget Function(
    T snapshot, ValueBuilderUpdateCallback<T> updater);

/// Manages a local state like ObxValue, but uses a callback instead of a Rx value.
///
/// Example:
/// ```
/// ValueBuilder<bool>(
///   initialValue: false,
///   builder: (value, update) => Switch(
///     value: value,
///     onChanged: (flag) {
///       update(flag);
///     },
///   ),
///   onUpdate: (value) => print("Value updated: $value"),
/// ),
/// ```
class ValueBuilder<T> extends StatefulWidget {
  final T initialValue;
  final ValueBuilderBuilder<T> builder;
  final void Function()? onDispose;
  final void Function(T)? onUpdate;

  const ValueBuilder({
    super.key,
    required this.initialValue,
    this.onDispose,
    this.onUpdate,
    required this.builder,
  });

  @override
  ValueBuilderState<T> createState() => ValueBuilderState<T>();
}

/// Manages local state like ObxValue, but uses a callback instead of an Rx value.
///
/// Example:
/// ```
///  ValueBuilder<bool>(
///    initialValue: false,
///    builder: (value, update) => Switch(
///    value: value,
///    onChanged: (flag) {
///       update( flag );
///    },),
///    onUpdate: (value) => print("value updated: $value"),
///  ),
///  ```

class ValueBuilderState<T> extends State<ValueBuilder<T>> {
  late T value;
  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.builder(value, updater);

  void updater(T newValue) {
    if (widget.onUpdate != null) {
      widget.onUpdate!(newValue);
    }
    setState(() {
      value = newValue;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.onDispose?.call();
    if (value is ChangeNotifier) {
      (value as ChangeNotifier?)?.dispose();
    } else if (value is StreamController) {
      (value as StreamController?)?.close();
    }
  }
}

/// DeexElement is a class that extends StatelessElement and mixes in StatelessObserverComponent
class DeexElement = StatelessElement with StatelessObserverComponent;

/// It's a experimental feature
class Observer extends DeexStatelessWidget {
  final WidgetBuilder builder;

  const Observer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context);
}

/// A StatelessWidget that can listen to reactive changes.
abstract class DeexStatelessWidget extends StatelessWidget {
  /// Initializes [key] for subclasses.
  const DeexStatelessWidget({super.key});
  @override
  StatelessElement createElement() => DeexElement(this);
}

/// A component that can track changes in a reactive variable
mixin StatelessObserverComponent on StatelessElement {
  List<Disposer>? disposers = <Disposer>[];

  void getUpdate() {
    if (disposers != null) {
      scheduleMicrotask(markNeedsBuild);
    }
  }

  @override
  Widget build() {
    return Notifier.instance.append(
        NotifyData(disposers: disposers!, updater: getUpdate), super.build);
  }

  @override
  void unmount() {
    super.unmount();
    for (final disposer in disposers!) {
      disposer();
    }
    disposers!.clear();
    disposers = null;
  }
}
