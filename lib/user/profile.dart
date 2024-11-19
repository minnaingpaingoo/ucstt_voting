import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ucstt_voting/services/database.dart';
import 'package:ucstt_voting/services/shared_pref.dart';
import 'package:ucstt_voting/user/bottom_nav/bottomnav.dart';
import 'package:ucstt_voting/user/terms_and_conditions.dart';
import 'package:ucstt_voting/user/voted_list.dart';
    
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String? className, name, email, id;
  
  Future<void> getthesharedpref() async {
    final prefs = await Future.wait([
      SharedPreferenceHelper().getUserId(),
      SharedPreferenceHelper().getUserClassName(),
      SharedPreferenceHelper().getUserName(),
      SharedPreferenceHelper().getUserEmail(),
    ]);
    id = prefs[0];
    className = prefs[1];
    name = prefs[2];
    email = prefs[3];

    if (mounted) {
      setState(() {});
    }
  }


  ontheload(){
    getthesharedpref();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState(){
    ontheload();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> votedList(BuildContext context) async {
    Navigator.push(context,MaterialPageRoute(builder: (context) => const VotedList()));
  }

  Future<void> deleteAccount(BuildContext context) async {
    // Show confirmation dialog
    bool confirmDeleteAcc = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete Account"),
          content: const Text("Are you sure you want to delete your account?"),
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

    // Check if user confirmed deleted account
    if (confirmDeleteAcc) {
      User? user = FirebaseAuth.instance.currentUser;
      user?.delete();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const BottomNav()));
    }
  }


  void editName(String userId, String userName) async {
    String? updatedName = await showEditNameDialog(context, userId, userName);
    if (updatedName != null) {
      setState(() {
        name = updatedName; // Update the state with the new name and refresh UI
      });
    }
  }

  void editClassName(String userId, String classname) async {
    String? updatedClassName = await showEditClassNameDialog(context, userId, classname);
    if (updatedClassName != null) {
      setState(() {
        className = updatedClassName; // Update the state with the new class name and refresh UI
      });
    }
  }

  Future <String?> showEditNameDialog(BuildContext context, String id, String name) async {

    final TextEditingController nameController = TextEditingController(text: name);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Edit Name"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    hintText: "Enter New Name",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Update"),
                onPressed: () async {

                  if(nameController.text.trim().isNotEmpty){

                    await DatabaseMethods().updateUserName(id, nameController.text.trim());
                    await SharedPreferenceHelper().saveUserName(nameController.text.trim());
            
                    //setState(() {});
            
                    Navigator.of(context).pop(nameController.text.trim());

                  }else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Invalid Name"),
                          content: const Text("Please enter new name"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future <String?> showEditClassNameDialog(BuildContext context, String id, String className) async {

    final TextEditingController classNameController = TextEditingController(text: className);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Edit Class Name"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: classNameController,
                  keyboardType: TextInputType.name,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    hintText: "Enter New Class Name",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Update"),
                onPressed: () async {

                  if(classNameController.text.trim().isNotEmpty){

                    await DatabaseMethods().updateUserClassName(id, classNameController.text.trim());
                    await SharedPreferenceHelper().saveUserClassName(classNameController.text.trim());
            
                    //setState(() {});
            
                    Navigator.of(context).pop(classNameController.text.trim());

                  }else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Invalid Class Name"),
                          content: const Text("Please enter new class name"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget infoRow({required IconData icon, required String title, required String value, VoidCallback? onEdit,}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.black),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActionRow({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future <void> termsAndConditions(BuildContext context)async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditions()));
  }

  Future<void> changePassword(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmNewPasswordController = TextEditingController();
    final FirebaseAuth auth = FirebaseAuth.instance;

    String? currentPasswordError;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Change Password"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      border: const OutlineInputBorder(),
                      errorText: currentPasswordError,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your current password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a new password";
                      } else if (value.length < 6) {
                        return "Password must be at least 6 characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmNewPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm New Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your new password";
                      } else if (value != newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close the dialog
                      auth.sendPasswordResetEmail(email: auth.currentUser!.email!);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            title: Text("Reset Password"),
                            content: Text("Password reset email sent!"),
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      String currentPassword = currentPasswordController.text.trim();
                      String newPassword = newPasswordController.text.trim();

                      User? user = auth.currentUser;
                      String email = user?.email ?? "";

                      // Reauthenticate user
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: email,
                        password: currentPassword,
                      );
                      await user?.reauthenticateWithCredential(credential);

                      // Update password
                      await user?.updatePassword(newPassword);
                      Navigator.of(context).pop(); // Close dialog

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            title: Text("Success"),
                            content: Text("Password changed successfully!"),
                          );
                        },
                      );
                    } catch (e) {
                      if (e.toString().contains('wrong-password')) {
                        currentPasswordError = "The current password is incorrect";
                      } else {
                        currentPasswordError = null;
                      }

                      // Trigger UI update to show error message
                      (formKey.currentState as FormState).validate();
                    }
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget buildProfileBody() {
    if (name == null || email == null || className == null) {
      return const Center(
        child: Text(
          "Login First",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
                height: MediaQuery.of(context).size.height / 4.3,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width, 105),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 6.5),
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        "images/avatar.png",
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Text(
                    name!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppin',
                    ),
                  ),
                ),
              ),
            ],
          ),
          infoRow(
            icon: Icons.person,
            title: "Name",
            value: name!,
            onEdit: () => editName(id!, name!),
          ),
          infoRow(
            icon: Icons.email,
            title: "Email",
            value: email!,
          ),
          infoRow(
            icon: Icons.person,
            title: "Class Name",
            value: className!,
            onEdit: () => editClassName(id!, className!),
          ),
          const SizedBox(height: 10),
          buildActionRow(
            icon: Icons.how_to_vote_outlined,
            label: "Your Voted List",
            onTap: () => votedList(context),
          ),
          const SizedBox(height: 10),
          buildActionRow(
            icon: Icons.settings,
            label: "Change Password",
            onTap: () => changePassword(context),
          ),
          const SizedBox(height: 10),
          buildActionRow(
            icon: Icons.edit_document,
            label: "Terms & Conditions",
            onTap: () => termsAndConditions(context),
          ),
          const SizedBox(height: 10),
          infoRow(
            icon: Icons.home,
            title: "Developed by Min Naing Paing Oo",
            value: "naingpaingoo@gmail.com",
          ),
          const SizedBox(height: 10),
          buildActionRow(
            icon: Icons.delete,
            label: "Delete Account",
            onTap: () => deleteAccount(context),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildProfileBody(),
    );
  }

}