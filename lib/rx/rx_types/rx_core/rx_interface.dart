part of '../rx_types.dart';

/// This class is the foundation for all reactive (Rx) classes that makes so powerful.
/// This interface is the contract that [_RxImpl]<T> uses in all it's
/// subclass.
abstract class DeexInterface<T> implements ValueListenable<T> {
  /// Close the Rx Variable
  void close();

  /// Calls `callback` with current value, when the value changes.
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError});
}

class ObxError {
  const ObxError();
  @override
  String toString() {
    return """
      [Deex] The stream has already been listened to.
      """;
  }
}
