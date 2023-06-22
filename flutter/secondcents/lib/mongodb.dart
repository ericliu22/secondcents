import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';

const MONGO_URL = ""; //Insert URL here later

class MongoDatabase {
  static connect() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
  }
}
