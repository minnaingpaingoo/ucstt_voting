import 'package:flutter/material.dart';
import 'package:ucstt_voting/services/database.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "User List",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search by name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          // User List
          Expanded(
            child: StreamBuilder(
              stream: DatabaseMethods().fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                final users = snapshot.data!.docs.where((user) {
                  final name = user['Name']?.toLowerCase() ?? '';
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data();
                    final userId = users[index].id;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person, color: Colors.black),
                        ),
                        title: Text(
                          user['Name'] ?? 'No Name',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Email: ${user['Email'] ?? 'No Email'}\nClass: ${user['Class'] ?? 'No Class'}",
                        ),
                        onTap: () {
                          _viewUserDetails(userId, user);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // View user details function
  void _viewUserDetails(String userId, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user['Name'] ?? 'No Name'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email: ${user['Email'] ?? 'No Email'}"),
                const SizedBox(height: 5),
                Text("Class: ${user['Class'] ?? 'No Class'}"),
                const SizedBox(height: 5),
                Text("Voted: ${user['Voted'] ?? 'No Vote'}"),
                const SizedBox(height: 5),
                const Text("Profile Image"),
                const SizedBox(height: 10),
                user['Profile'] != null && user['Profile'].isNotEmpty
                    ? Image.network(
                        user['Profile']!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "images/avatar.png",
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset("images/avatar.png", width: 120, height: 120, fit: BoxFit.cover),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
