// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:secondcents/schemas/user.dart' as user_schema;
import 'globals.dart';

Future<void> main() async {
  // ignore: constant_identifier_names
  const String APP_ID = "twocents-pmukp";
  final appConfig = AppConfiguration(APP_ID);
  app = ValueNotifier<App>(App(appConfig));

  const String email = "jenniekim@gmail.com";
  const String password = "blackpinkinyourarea";
  const String displayName = "Jennie Kim";
  const String username = "jennierubyjane";
  final File pictureFile = File("resources/images/jennie kim.jpg");
  final List<int> imageBytes = imageFileToBytes(pictureFile);

  await emailRegister(email, password);
  await emailLogin(
    email,
    password,
    displayName: displayName,
    username: username,
    profilePic: imageBytes,
  );

  final config =
      Configuration.flexibleSync(currentUser.value, [user_schema.User.schema]);
  user_realm = ValueNotifier<Realm>(Realm(config));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> emailRegister(String email, String password) async {
  EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app.value);
  try {
    await authProvider.registerUser(email, password);
    print("Not in use");
  } on AppException catch (e) {
    if (e.message.contains("name already in use")) {
      print("Email already in use");
    } else {
      rethrow;
    }
  }
}

Future<void> emailLogin(String email, String password,
    {bool register = false,
    String displayName = "",
    String username = "",
    List<int>? profilePic}) async {
  Credentials credentials = Credentials.emailPassword(email, password);
  currentUser = ValueNotifier<User>(await app.value.logIn(credentials));
  if (register) {
    createUserDocument(profilePic, displayName, username);
  }
}

void createUserDocument(
    List<int>? imageBytes, String displayName, String username) {
  ObjectId id = ObjectId.fromHexString(currentUser.value.id);
  user_schema.User newUser;
  if (imageBytes != null) {
    Iterable<int> bytes = imageBytes;
    newUser = user_schema.User(id, displayName, username, profilePic: bytes);
  } else {
    newUser = user_schema.User(id, displayName, username);
  }
  user_realm.value.write(() {
    user_realm.value.add(newUser);
  });
}

List<int> imageFileToBytes(var imageFile) {
  List<int> imageBytes = imageFile.readAsBytesSync();
  return imageBytes;
}
