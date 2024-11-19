import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ucstt_voting/user/home.dart';
import 'package:ucstt_voting/user/profile.dart';
import 'package:ucstt_voting/user/vote.dart';
import 'package:ucstt_voting/services/database.dart';
import 'package:ucstt_voting/services/shared_pref.dart';
import 'package:ucstt_voting/admin/admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  //static final GlobalKey<BottomNavState> bottomNavKey = GlobalKey<BottomNavState>();

  @override
  State<BottomNav> createState() => BottomNavState();
}

class BottomNavState extends State<BottomNav> {

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPage;
  late Home homepage;
  late Profile profile;
  late Vote vote;

  bool isDarkMode = false;
  String? email;
  String? name;
  String? password;
  String? className;
  final _formKeyRegister = GlobalKey<FormState>();

  String? loginEmail;
  String? loginPassword;
  final _formKeyLogin = GlobalKey<FormState>();

  String? resetPasswordEmail;
  String? emailError;

  void navigateToAdminPage(BuildContext context) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
      //showSuccessSnackBar("Welcome Admin!");
    }
  }

  void navigateToUserPage(BuildContext context) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );
      //showSuccessSnackBar("Login Successfully!");
    }
  }

  void showErrorSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.green),
        ),
      ),
    );
  }

  void handleLoginError(String errorCode, String? errorMessage) {
    String message;
    switch (errorCode) {
      case 'user-not-found':
        message = "No user found with this email.";
        break;
      case 'wrong-password':
        message = "Incorrect password.";
        break;
      case 'invalid-email':
        message = "The email address is not valid.";
        break;
      default:
        message = errorMessage ?? "An unexpected error occurred.";
    }

    // Show a SnackBar with the error message
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 18, color: Colors.redAccent),
        ),
      ),
    );
  }


  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferenceHelper helper = SharedPreferenceHelper();
    await helper.saveUserId(userData['Id']);
    await helper.saveUserName(userData['Name']);
    await helper.saveUserEmail(userData['Email']);
    await helper.saveUserClassName(userData['Class']);
  }

  Future<void> userLogin(BuildContext context) async {
    try {

      // Check in Admin Collection
      final adminQuery = await FirebaseFirestore.instance
          .collection('Admin')
          .where('Email', isEqualTo: loginEmail)
          .where('Password', isEqualTo: loginPassword)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        navigateToAdminPage(context);
        return;
      }
      
      // Authenticate User
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmail!,
        password: loginPassword!,
      );

      // Get User UID
      String uid = userCredential.user!.uid;
  
      // Fetch User Data and Navigate
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
    

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        await saveUserData(userData);
        navigateToUserPage(context);
        return;
      }else{
        showErrorSnackBar("Incorrect Email or Password!");
        return;
      }
      
    } on FirebaseAuthException catch (e) {
      handleLoginError(e.code, e.message);
    }
  }

  void showLoginDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login'),
          content: Form(
            key: _formKeyLogin,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter Email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Your Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  TextFormField(
                    controller: passwordController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter Password';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Your Password',
                      prefixIcon: Icon(Icons.password_outlined),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close login dialog
                      showRegisterDialog(context);
                    },
                    child: const Text(
                      "Don't have an account? Register",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close the dialog
                      showPasswordResetDialog(context);
                    },
                    child: const Text(
                      "Forgot Password? Reset!",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async{
                if(_formKeyLogin.currentState!.validate()){
                  loginEmail = emailController.text.trim();
                  loginPassword = passwordController.text.trim();
                  await userLogin(context);
                }

                await SharedPreferenceHelper().getUserName().then((fetchedName){
                  if(mounted){
                    setState((){
                      name = fetchedName;
                    });
                  }
                });
                
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future <void> registration() async {
    if(password!.isNotEmpty){
      try{
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email!, password: password!);
        Navigator.pop(context);

        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Text(
              "Register Successfully!!",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        );
        String userId = userCredential.user!.uid;
        Map<String, dynamic> addUserInfo = {
          "Name": name!,
          "Email": email!,
          "Class": className!,
          "Id": userId,
        };
        //Save to the firestore
        await DatabaseMethods().addUserDetail(addUserInfo, userId);
        //Save to the SharedPreferenceHelper
        await SharedPreferenceHelper().saveUserName(name!);
        await SharedPreferenceHelper().saveUserEmail(email!);
        await SharedPreferenceHelper().saveUserClassName(className!);
        await SharedPreferenceHelper().saveUserId(userId);

        setState(() {
          name = SharedPreferenceHelper().getUserName() as String?;
        });

      }on FirebaseException catch(e){
        if(e.code == 'weak-password'){
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text(
                "Password Provided is too Weak!!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
            ),
          );
        }else if(e.code == 'email-already-in-use'){
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text(
                "Account already exist!!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
          );
        }else if(e.code == 'invalid-email'){
          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text(
                "Invalid email format!!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
            ),
          );
        }
      }
    }
  }

  Future <void> resetPassword() async {
    if(resetPasswordEmail!.isNotEmpty){
      try{
        await FirebaseAuth.instance.sendPasswordResetEmail(email: resetPasswordEmail!);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Reset Password"),
              content: Text("Password reset email sent!"),
            );
          },
        );
      }catch (e) {
          if (e.toString().contains("user-not-found")) {
            setState(() {
              emailError = "Email not found. Please try again.";
            });
          } else {
            setState(() {
              emailError = "An error occurred. Please try again.";
            });
          }
      }
    } else {
      setState(() {
        emailError = "Please enter an email address.";
      });
    }
  }

  void showRegisterDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController classController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKeyRegister,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter Name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter Your Name',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter Email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Your Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  TextFormField(
                    controller: passwordController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter Password';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Your Password',
                      prefixIcon: Icon(Icons.password_outlined),
                    ),
                    obscureText: true,
                  ),
                  TextFormField(
                    controller: classController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter Class Name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Class Name',
                      hintText: 'Enter Your Class Name eg. First Year(A), Second Year (CS)',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close login dialog
                      showLoginDialog(context);
                    },
                    child: const Text(
                      "Have already account? Login",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async{
                if(_formKeyRegister.currentState!.validate()){
                  email = emailController.text;
                  name = nameController.text;
                  password = passwordController.text;
                  className = classController.text;
                  await registration();
                }             
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void showPasswordResetDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Password Reset'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKeyRegister,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please Enter Email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Your Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close login dialog
                      showLoginDialog(context);
                    },
                    child: const Text(
                      "Have already account? Login",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async{
                if(_formKeyRegister.currentState!.validate()){
                  resetPasswordEmail = emailController.text.trim();
                  await resetPassword();
                }             
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    // Show confirmation dialog
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if canceled
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
            ),
          ],
        );
      },
    );

    // Check if user confirmed logout
    if (confirmLogout) {
      await SharedPreferenceHelper().clearUserData();
      await FirebaseAuth.instance.signOut();

      if(mounted){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const BottomNav()));
      }
      
    }
  }

   getthesharepref() async {
    // Simulate loading user name from shared preferences
    name = await SharedPreferenceHelper().getUserName();
    if (mounted) {
      setState(() {});
    }
  }

  ontheload() async {
    await getthesharepref();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState(){
    ontheload();
    homepage = const Home();
    vote = const Vote();
    profile = const Profile();
    pages = [homepage, vote, profile];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, 
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Hello, ${name ?? 'User'}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            // Dark Mode Toggle
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                if (name == null) {
                  showLoginDialog(context);
                } else {
                  logout(context);
                  setState(() {
                    
                  });
                }
              },
              child: Text(name == null ? "Login" : "Logout"),
            ),
            const SizedBox(width: 10),
          ]
        ),
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.black,
          height: 65,
          backgroundColor: Colors.white,
          animationDuration: const Duration(milliseconds: 500),
          onTap: (int index){
            setState(() {
              currentTabIndex = index;
            });
          },
          items:const [
            Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.how_to_vote,
              color: Colors.white,
            ),
            Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ],
        ),
        body: pages[currentTabIndex],
      ),
    );
  }
}