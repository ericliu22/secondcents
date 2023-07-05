// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Space extends _Space with RealmEntity, RealmObjectBase, RealmObject {
  Space(
    ObjectId spaceId,
    String name,
    String spacePhoto,
    int userCount, {
    Iterable<String> userList = const [],
    Iterable<String> bubbleList = const [],
  }) {
    RealmObjectBase.set(this, '_id', spaceId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'spacePhoto', spacePhoto);
    RealmObjectBase.set(this, 'userCount', userCount);
    RealmObjectBase.set<RealmList<String>>(
        this, 'userList', RealmList<String>(userList));
    RealmObjectBase.set<RealmList<String>>(
        this, 'bubbleList', RealmList<String>(bubbleList));
  }

  Space._();

  @override
  ObjectId get spaceId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set spaceId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get spacePhoto =>
      RealmObjectBase.get<String>(this, 'spacePhoto') as String;
  @override
  set spacePhoto(String value) =>
      RealmObjectBase.set(this, 'spacePhoto', value);

  @override
  int get userCount => RealmObjectBase.get<int>(this, 'userCount') as int;
  @override
  set userCount(int value) => RealmObjectBase.set(this, 'userCount', value);

  @override
  RealmList<String> get userList =>
      RealmObjectBase.get<String>(this, 'userList') as RealmList<String>;
  @override
  set userList(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String> get bubbleList =>
      RealmObjectBase.get<String>(this, 'bubbleList') as RealmList<String>;
  @override
  set bubbleList(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Space>> get changes =>
      RealmObjectBase.getChanges<Space>(this);

  @override
  Space freeze() => RealmObjectBase.freezeObject<Space>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Space._);
    return const SchemaObject(ObjectType.realmObject, Space, 'Space', [
      SchemaProperty('spaceId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('spacePhoto', RealmPropertyType.string),
      SchemaProperty('userCount', RealmPropertyType.int),
      SchemaProperty('userList', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('bubbleList', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
    ]);
  }
}
