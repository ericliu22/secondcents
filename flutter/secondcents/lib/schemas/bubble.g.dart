// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bubble.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Bubble extends _Bubble with RealmEntity, RealmObjectBase, RealmObject {
  Bubble(
    ObjectId bubbleId,
    String type,
    String ownerId,
  ) {
    RealmObjectBase.set(this, '_id', bubbleId);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'ownerId', ownerId);
  }

  Bubble._();

  @override
  ObjectId get bubbleId =>
      RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set bubbleId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'ownerId') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  Stream<RealmObjectChanges<Bubble>> get changes =>
      RealmObjectBase.getChanges<Bubble>(this);

  @override
  Bubble freeze() => RealmObjectBase.freezeObject<Bubble>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Bubble._);
    return const SchemaObject(ObjectType.realmObject, Bubble, 'Bubble', [
      SchemaProperty('bubbleId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('ownerId', RealmPropertyType.string),
    ]);
  }
}
