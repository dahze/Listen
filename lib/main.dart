import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:listen/core/di/injection_container.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  runApp(const ListenApp());
}
