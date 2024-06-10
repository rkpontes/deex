import 'package:flutter/widgets.dart';

import '../../rx/rx_types/rx_types.dart';
import '../simple/simple_builder.dart';

typedef WidgetCallback = Widget Function();

/// The [RxWidget] is the base for all GetX reactive widgets
///
/// See also:
/// - [Deex]
/// - [RxValue]
abstract class RxWidget extends DeexStatelessWidget {
  const RxWidget({super.key});
}

/// The simplest reactive widget in GetX.
///
/// Just pass your Rx variable in the root scope of the callback to have it
/// automatically registered for changes.
///
/// final _name = "GetX".obs;
/// Obx(() => Text( _name.value )),... ;
class Deex extends RxWidget {
  final WidgetCallback builder;

  const Deex(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

/// Similar to Obx, but manages a local state.
/// Pass the initial data in constructor.
/// Useful for simple local states, like toggles, visibility, themes,
/// button states, etc.
///  Sample:
///    ObxValue((data) => Switch(
///      value: data.value,
///      onChanged: (flag) => data.value = flag,
///    ),
///    false.obs,
///   ),
class RxValue<T extends DeexInterface> extends RxWidget {
  final Widget Function(T) builder;
  final T data;

  const RxValue(this.builder, this.data, {super.key});

  @override
  Widget build(BuildContext context) => builder(data);
}
