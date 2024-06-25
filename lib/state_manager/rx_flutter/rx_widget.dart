import 'package:flutter/widgets.dart';

import '../../rx/rx_types/rx_types.dart';
import '../widgets/simple_builder.dart';

typedef WidgetCallback = Widget Function();

/// The [RxWidget] is the base for all Deex reactive widgets
///
/// See also:
/// - [Deex]
/// - [DeexValue]
abstract class RxWidget extends DeexStatelessWidget {
  const RxWidget({super.key});
}

/// The simplest reactive widget in Deex.
///
/// Just pass your Rx variable in the root scope of the callback to have it
/// automatically registered for changes.
///
/// final _name = "Deex".obs;
/// Obx(() => Text( _name.value )),... ;
class Deex extends RxWidget {
  final WidgetCallback builder;

  const Deex(this.builder, {super.key});

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

/// Similar to Deex, but manages a local state.
/// Pass the initial data in constructor.
/// Useful for simple local states, like toggles, visibility, themes,
/// button states, etc.
///  Sample:
///    DeexValue((data) => Switch(
///      value: data.value,
///      onChanged: (flag) => data.value = flag,
///    ),
///    false.obs,
///   ),
class DeexValue<T extends DeexInterface> extends RxWidget {
  final Widget Function(T) builder;
  final T data;

  const DeexValue(this.builder, this.data, {super.key});

  @override
  Widget build(BuildContext context) => builder(data);
}
