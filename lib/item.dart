import 'package:realm/realm.dart';

part 'item.g.dart';

@RealmModel()
class _Item {
  late int id;

  late String name;
  late int quantity;

  late DateTime createdAt;
  
  late bool isPaid;
  
  void toggleChecked() {
    isPaid = !isPaid;
  }
}
