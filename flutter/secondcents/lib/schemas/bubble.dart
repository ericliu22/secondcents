import "package:realm/realm.dart" as realm;
import "package:realm/realm.dart";

part 'bubble.g.dart';

@RealmModel()
class _Bubble {
  @MapTo("_id")
  @PrimaryKey()
  late realm.ObjectId bubbleId;

  late String type;
  late String ownerId;
}
