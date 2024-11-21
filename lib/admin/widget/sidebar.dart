// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ucstt_voting/admin/add_category.dart';
import 'package:ucstt_voting/admin/add_selection.dart';
import 'package:ucstt_voting/admin/manage_category.dart';
import 'package:ucstt_voting/admin/manage_selection.dart';
import 'package:ucstt_voting/admin/master_setting/master_setting.dart';
import 'package:ucstt_voting/admin/user_list.dart';
import 'package:ucstt_voting/services/shared_pref.dart';
import 'package:ucstt_voting/user/bottom_nav/bottomnav.dart';

// ignore: must_be_immutable
class Sidebar extends StatefulWidget {
  bool isDarkMode;
  Sidebar({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDarkMode ? Colors.black : Colors.grey[200],
      child: SizedBox(
        width: 250,
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_chart),
              title: const Text('Add Category'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddCategory()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Manage Category'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const ManageCategory()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Add Selection'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddSelection()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.change_circle_outlined),
              title: const Text('Manage Selection'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const  ManageSelection()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User List'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const UserList()));
              },
            ),
             ListTile(
              leading: const Icon(Icons.app_settings_alt),
              title: const Text('Master Setting'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const MasterSetting()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async{
                // Show confirmation dialog
                bool confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to logout?"),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const BottomNav()));
                }
                
              },
            ),
          ],
        ),
      ),
    );
  }
}
