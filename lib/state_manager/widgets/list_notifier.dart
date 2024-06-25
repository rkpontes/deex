import 'dart:collection';

import 'package:flutter/foundation.dart';

/// This callback removes the listener added by the addListener function.
typedef Disposer = void Function();

/// Replaces StateSetter, returning if the Widget is mounted for extra validation.
typedef DeexStateUpdate = void Function();

/// A ListNotifier with both single and group listener support.
class ListNotifier extends Listenable
    with ListNotifierSingleMixin, ListNotifierGroupMixin {}

/// A Notifier with single listeners
///
/// Example:
/// ```
/// class MyWidget extends StatefulWidget {
///   @override
///   _MyWidgetState createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final ListNotifierSingle _notifier = ListNotifierSingle();
///   @override
///   void initState() {
///     super.initState();
///     _notifier.addListener(() {
///       setState(() {});
///     });
///   }
///
///   @override
///   void dispose() {
///     _notifier.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ElevatedButton(
///       onPressed: () {
///         _notifier.refresh();
///       },
///       child: Text('Refresh'),
///     );
///   }
/// }
///```
class ListNotifierSingle = ListNotifier with ListNotifierSingleMixin;

/// A notifier with a group of listeners identified by an ID.
///
/// Example:
/// ```
/// class MyGroupWidget extends StatefulWidget {
///   @override
///   _MyGroupWidgetState createState() => _MyGroupWidgetState();
/// }
///
/// class _MyGroupWidgetState extends State<MyGroupWidget> {
///   final ListNotifierGroup _notifier = ListNotifierGroup();
///
///   @override
///   void initState() {
///     super.initState();
///     _notifier.addListenerId('button1', () {
///       setState(() {});
///     });
///   }
///
///   @override
///   void dispose() {
///     _notifier.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         ElevatedButton(
///           onPressed: () {
///             _notifier.refreshGroup('button1');
///           },
///           child: Text('Refresh Button 1'),
///         ),
///         ElevatedButton(
///           onPressed: () {
///             _notifier.refreshGroup('button2');
///           },
///           child: Text('Refresh Button 2'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
class ListNotifierGroup = ListNotifier with ListNotifierGroupMixin;

/// This mixin adds addListener, removeListener, and containsListener implementation to Listenable.
mixin ListNotifierSingleMixin on Listenable {
  List<DeexStateUpdate>? _updaters = <DeexStateUpdate>[];

  @override
  Disposer addListener(DeexStateUpdate listener) {
    assert(_debugAssertNotDisposed());
    _updaters!.add(listener);
    return () => _updaters!.remove(listener);
  }

  bool containsListener(DeexStateUpdate listener) {
    return _updaters?.contains(listener) ?? false;
  }

  @override
  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _updaters!.remove(listener);
  }

  @protected
  void refresh() {
    assert(_debugAssertNotDisposed());
    _notifyUpdate();
  }

  @protected
  void reportRead() {
    Notifier.instance.read(this);
  }

  @protected
  void reportAdd(VoidCallback disposer) {
    Notifier.instance.add(disposer);
  }

  void _notifyUpdate() {
    // if (_microtaskVersion == _version) {
    //   _microtaskVersion++;
    //   scheduleMicrotask(() {
    //     _version++;
    //     _microtaskVersion = _version;
    final list = _updaters?.toList() ?? [];

    for (var element in list) {
      element();
    }
    //   });
    // }
  }

  bool get isDisposed => _updaters == null;

  bool _debugAssertNotDisposed() {
    assert(() {
      if (isDisposed) {
        throw FlutterError('''A $runtimeType was used after being disposed.\n
'Once you have called dispose() on a $runtimeType, it can no longer be used.''');
      }
      return true;
    }());
    return true;
  }

  int get listenersLength {
    assert(_debugAssertNotDisposed());
    return _updaters!.length;
  }

  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _updaters = null;
  }
}

/// This mixin adds group listener support to Listenable.
mixin ListNotifierGroupMixin on Listenable {
  HashMap<Object?, ListNotifierSingleMixin>? _updatersGroupIds =
      HashMap<Object?, ListNotifierSingleMixin>();

  void _notifyGroupUpdate(Object id) {
    if (_updatersGroupIds!.containsKey(id)) {
      _updatersGroupIds![id]!._notifyUpdate();
    }
  }

  @protected
  void notifyGroupChildrens(Object id) {
    assert(_debugAssertNotDisposed());
    Notifier.instance.read(_updatersGroupIds![id]!);
  }

  bool containsId(Object id) {
    return _updatersGroupIds?.containsKey(id) ?? false;
  }

  @protected
  void refreshGroup(Object id) {
    assert(_debugAssertNotDisposed());
    _notifyGroupUpdate(id);
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_updatersGroupIds == null) {
        throw FlutterError('''A $runtimeType was used after being disposed.\n
'Once you have called dispose() on a $runtimeType, it can no longer be used.''');
      }
      return true;
    }());
    return true;
  }

  void removeListenerId(Object id, VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    if (_updatersGroupIds!.containsKey(id)) {
      _updatersGroupIds![id]!.removeListener(listener);
    }
  }

  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _updatersGroupIds?.forEach((key, value) => value.dispose());
    _updatersGroupIds = null;
  }

  Disposer addListenerId(Object? key, DeexStateUpdate listener) {
    _updatersGroupIds![key] ??= ListNotifierSingle();
    return _updatersGroupIds![key]!.addListener(listener);
  }

  /// Disposes an [id] to prevent future updates.
  /// These IDs are registered by `Deex()` or similar, allowing unlinking of state changes from the Widget to the Controller.
  void disposeId(Object id) {
    _updatersGroupIds?[id]?.dispose();
    _updatersGroupIds!.remove(id);
  }
}

/// Singleton class that manages notifiers.
class Notifier {
  Notifier._();

  static Notifier? _instance;
  static Notifier get instance => _instance ??= Notifier._();

  NotifyData? _notifyData;

  void add(VoidCallback listener) {
    _notifyData?.disposers.add(listener);
  }

  void read(ListNotifierSingleMixin updaters) {
    final listener = _notifyData?.updater;
    if (listener != null && !updaters.containsListener(listener)) {
      updaters.addListener(listener);
      add(() => updaters.removeListener(listener));
    }
  }

  T append<T>(NotifyData data, T Function() builder) {
    _notifyData = data;
    final result = builder();
    if (data.disposers.isEmpty && data.throwException) {
      throw const DeexError();
    }
    _notifyData = null;
    return result;
  }
}

/// Class representing the data for notifications.
class NotifyData {
  const NotifyData(
      {required this.updater,
      required this.disposers,
      this.throwException = true});
  final DeexStateUpdate updater;
  final List<VoidCallback> disposers;
  final bool throwException;
}

/// Error class for Deex errors.
class DeexError {
  const DeexError();
  @override
  String toString() {
    return """
      [Deex] The stream has already been listened to.
      """;
  }
}
