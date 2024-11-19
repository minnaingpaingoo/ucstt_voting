import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ucstt_voting/admin/widget/sidebar.dart';
import 'package:ucstt_voting/services/database.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  List<Map<String, dynamic>> allSelection =[];
  
  int numberOfCategories = 0;
  int numberOfSelections = 0;
  int numberOfUsers = 0;
  int numberOfVotedUsers = 0;

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    // Fetch number of categories
    final categoriesSnapshot =await DatabaseMethods().getNumberOfCategory();
    numberOfCategories = categoriesSnapshot.docs.length;

    // Fetch number of selections
    allSelection = await DatabaseMethods().getAllSelections();
    numberOfSelections = allSelection.length;

    // Fetch number of users
    final usersSnapshot = await DatabaseMethods().getNumberOfUser();
    numberOfUsers = usersSnapshot.docs.length;

    // Fetch number of voted users
    final votedUsersSnapshot = await DatabaseMethods().getNumberOfVotedUser();
    numberOfVotedUsers = votedUsersSnapshot.docs.length;

    print("Number of Voted Users");
    print(numberOfVotedUsers);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Dynamic theme
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode; // Toggle theme mode
                });
              },
            ),
          ],
        ),
        body: Row(
          children: [
            // Sidebar for large screens
            if (!isMobile) Expanded(flex: 2, child: Sidebar(isDarkMode: isDarkMode)),

            // Main Content Area
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Statistics
                    Text(
                      'Dashboard Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        buildStatCard('Total Category', numberOfCategories, Colors.green),
                        buildStatCard('Total Selection', numberOfSelections, Colors.yellow),
                        buildStatCard('Total User', numberOfUsers, Colors.blue),
                        buildStatCard('Total Voted User', numberOfVotedUsers, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Top 3 Selections for Each Category
                    Text(
                      'Top 3 Selections',
                      style: TextStyle(
                        fontSize: 24,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildTopSelections(),

                    const SizedBox(height: 24),

                    // Section 3: Full List of Selections
                    Text(
                      'List of All Selections',
                      style: TextStyle(
                        fontSize: 24,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildSelectionsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
        drawer: isMobile ? Sidebar(isDarkMode: isDarkMode) : null,
      ),
    );
  }

  Widget buildStatCard(String title, int count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopSelections() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Categories').orderBy('CategoryName').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var category = snapshot.data!.docs[index];

            return StreamBuilder(
              stream: DatabaseMethods().getTopThreeSelection(category.id),
              builder: (context, AsyncSnapshot<QuerySnapshot> selectionsSnapshot) {
                if (!selectionsSnapshot.hasData) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['CategoryName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...selectionsSnapshot.data!.docs.map((doc) {
                      return ListTile(
                        leading: Image.network(doc['Image'], width: 50),
                        title: Text(doc['Name']),
                        subtitle: Text('Votes: ${doc['Votes']}'),
                      );
                    }),
                    const Divider(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildSelectionsList() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('Categories').orderBy('CategoryName').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var category = snapshot.data!.docs[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['CategoryName'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: DatabaseMethods().getAllSelectionList(category.id),
                  builder: (context, AsyncSnapshot<QuerySnapshot> selectionsSnapshot) {
                    if (!selectionsSnapshot.hasData) {
                      return const SizedBox();
                    }

                    return Column(
                      children: selectionsSnapshot.data!.docs.map((doc) {
                        return ListTile(
                          leading: Image.network(doc['Image'], width: 50),
                          title: Text(doc['Name']),
                          subtitle: Text('Votes: ${doc['Votes']}'),
                        );
                      }).toList(),
                    );
                  },
                ),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}
