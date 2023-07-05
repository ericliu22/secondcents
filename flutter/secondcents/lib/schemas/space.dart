import "package:realm/realm.dart" as realm;
import "package:realm/realm.dart";

part 'space.g.dart';

@RealmModel()
class _Space {
  @MapTo("_id")
  @PrimaryKey()
  late realm.ObjectId spaceId;

  late String name;
  late String spacePhoto;
  late int userCount;
  late List<String> userList;
  late List<String> bubbleList;
}
