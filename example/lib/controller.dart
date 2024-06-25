import 'package:deex/rx/rx_types/rx_types.dart';
import 'package:deex/state_manager/widgets/deex_store.dart';

class Controller extends DeexStore {
  List<String> titles = [
    "Page 1",
    "Page 2",
    "Page 3",
    "Page 4",
    "Page 5",
    "Page 6",
  ];

  var titleIndex = 0.obs;

  String get title => titles[titleIndex.value];

  void changeTitle() {
    titleIndex.value++;
    if (titleIndex.value >= titles.length) {
      titleIndex.value = 0;
    }
  }

  var count = 0.obs;
  void increment() => count++;
}
