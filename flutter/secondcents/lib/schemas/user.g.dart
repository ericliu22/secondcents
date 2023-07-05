// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class User extends _User with RealmEntity, RealmObjectBase, RealmObject {
  User(
    ObjectId userId,
    String username,
    String displayName, {
    Iterable<int> profilePic = const [],
  }) {
    RealmObjectBase.set(this, '_id', userId);
    RealmObjectBase.set(this, 'username', username);
    RealmObjectBase.set(this, 'displayName', displayName);
    RealmObjectBase.set<RealmList<int>>(
        this, 'profilePic', RealmList<int>(profilePic));
  }

  User._();

  @override
  ObjectId get userId => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set userId(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get username =>
      RealmObjectBase.get<String>(this, 'username') as String;
  @override
  set username(String value) => RealmObjectBase.set(this, 'username', value);

  @override
  String get displayName =>
      RealmObjectBase.get<String>(this, 'displayName') as String;
  @override
  set displayName(String value) =>
      RealmObjectBase.set(this, 'displayName', value);

  @override
  RealmList<int> get profilePic =>
      RealmObjectBase.get<int>(this, 'profilePic') as RealmList<int>;
  @override
  set profilePic(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<User>> get changes =>
      RealmObjectBase.getChanges<User>(this);

  @override
  User freeze() => RealmObjectBase.freezeObject<User>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(User._);
    return const SchemaObject(ObjectType.realmObject, User, 'User', [
      SchemaProperty('userId', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('username', RealmPropertyType.string),
      SchemaProperty('displayName', RealmPropertyType.string),
      SchemaProperty('profilePic', RealmPropertyType.int,
          collectionType: RealmCollectionType.list),
    ]);
  }
}
