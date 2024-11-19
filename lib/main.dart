import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ucstt_voting/user/loading.dart';
import 'package:ucstt_voting/user/welcome_screen/onboard.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the status bar color to match app theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Makes it blend with your Scaffold background
      statusBarIconBrightness: Brightness.dark, // Dark icons for light background
    ),
  );

  runApp(
    //MultiProvider(
      // providers: [
      //   ChangeNotifierProvider(create: (_)=> CartProvider())
      // ],
      //child: 
      const MyApp(),
    //),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
    routes:{
      '/': (context) => const Loading(),
      '/onboard': (context) => const Onboard(),
    },
    );
  }

}