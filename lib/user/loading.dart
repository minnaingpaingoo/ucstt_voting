import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();

    // Delay for 5 seconds before navigating to the next screen
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/onboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 150.0, // Adjust size as needed
          height: 150.0, // Adjust size as needed
        ),
      ),
    );
  }
}
