// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:secondcents/schemas/user.dart' as user_information;

late ValueNotifier<user_information.User> user_info;
late ValueNotifier<User> currentUser;
late ValueNotifier<Realm> realm;
late ValueNotifier<App> app;
