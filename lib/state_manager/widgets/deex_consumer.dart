import 'package:flutter/widgets.dart';
import 'deex_store.dart';

/// A function that returns a widget based on the `BuildContext` and the `DeexStore` state.
typedef DeexBuilder<S> = Widget Function(BuildContext context, S state);

/// A function that performs side effects based on the `BuildContext` and the `DeexStore` state.
typedef DeexListener<S> = void Function(BuildContext context, S state);

/// A widget that listens to a `DeexStore` and rebuilds when the state changes.
/// It combines both a `builder` and a `listener` callback.
///
/// Example:
/// ```
/// class CounterStore extends DeexStore {
///   int _count = 0;
///
///   int get count => _count;
///
///   void increment() {
///     _count++;
///     update();
///   }
/// }
///
/// class CounterPage extends StatelessWidget {
///   final CounterStore store = CounterStore();
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Counter')),
///       body: DeexConsumer<CounterStore>(
///         store: store,
///         listener: (context, store) {
///           // You can show a snack bar or perform other side effects here
///           ScaffoldMessenger.of(context).showSnackBar(
///             SnackBar(content: Text('Counter updated: ${store.count}')),
///           );
///         },
///         builder: (context, store) {
///           return Center(
///             child: Column(
///               mainAxisAlignment: MainAxisAlignment.center,
///               children: [
///                 Text('You have pushed the button this many times:'),
///                 Text('${store.count}', style: Theme.of(context).textTheme.headline4),
///               ],
///             ),
///           );
///         },
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: store.increment,
///         tooltip: 'Increment',
///         child: Icon(Icons.add),
///       ),
///     );
///   }
/// }
/// ```
class DeexConsumer<S extends DeexStore> extends StatefulWidget {
  final S store;
  final DeexBuilder<S> builder;
  final DeexListener<S>? listener;
  final List<Object>? listenIds;

  const DeexConsumer({
    super.key,
    required this.store,
    required this.builder,
    this.listener,
    this.listenIds,
  });

  @override
  DeexConsumerState<S> createState() => DeexConsumerState<S>();
}

class DeexConsumerState<S extends DeexStore> extends State<DeexConsumer<S>> {
  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdate);
    if (widget.listenIds != null) {
      for (var id in widget.listenIds!) {
        widget.store.addListenerId(id, _onStoreUpdate);
      }
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreUpdate);
    if (widget.listenIds != null) {
      for (var id in widget.listenIds!) {
        widget.store.removeListenerId(id, _onStoreUpdate);
      }
    }
    super.dispose();
  }

  void _onStoreUpdate() {
    if (widget.listener != null) {
      widget.listener!(context, widget.store);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.store);
  }
}
