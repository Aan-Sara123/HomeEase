import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/login.dart';
import 'users/profile_icon/profile_page.dart'; // Import the ProfilePage
import 'my_firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MyFirebaseMessagingService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeEase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginPage(),  // Ensure this exists
        '/home': (context) => const ProfilePage(), // Ensure this exists
      },
    );
  }
}
