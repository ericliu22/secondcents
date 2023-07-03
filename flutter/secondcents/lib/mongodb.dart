import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import "package:realm/realm.dart" as realm;
import "package:realm/realm.dart";

// ignore: constant_identifier_names
const MONGO_URL =
    "mongodb+srv://secondcents:<Two_C3nt\$_App_2023>@secondcents-1.aovv9i7.mongodb.net/"; //Insert URL here later

class MongoDatabase {
  static connect() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
  }
}

@RealmModel()
class User {
  @PrimaryKey()
  late realm.ObjectId userId;

  late String username;
  late String displayName;
  late String profilePic;
}
