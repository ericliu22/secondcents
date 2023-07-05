import "package:realm/realm.dart";

part 'user.g.dart';

@RealmModel()
class _User {
  @PrimaryKey()
  @MapTo('_id')
  ObjectId? id;
  late String displayName;
  late List<int> profilePic;
  late String username;
}

/*
==========================
HOW TO GENERATE A REALM SCHEMA
==========================
Schema is just custom class that you can read/write data from the database

Step 1:
Write the realm model like above.
Ensure that the model name has _ in front of it like _User or _Groupchat

Step 2:
Add "part <Whateverfilename>.g.dart;" to the realm model definition

Step 2:
Change directory to schemas

Step 3:
Use 'flutter pub run realm generate' in terminal
The documentation will tell you to 'dart run realm generate'
but this doesn't work. It will also say the command is deprecated ignore it
*/
