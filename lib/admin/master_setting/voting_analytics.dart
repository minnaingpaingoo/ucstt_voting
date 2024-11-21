import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ucstt_voting/services/database.dart';

class VotingAnalytics extends StatefulWidget {
  const VotingAnalytics({super.key});

  @override
  State<VotingAnalytics> createState() => _VotingAnalyticsState();
}

class _VotingAnalyticsState extends State<VotingAnalytics> {
  late Future<List<UserVoteData>> _userVotes;
  List<UserVoteData> _allUserVotes = [];
  List<UserVoteData> _filteredUserVotes = [];
  String searchQuery = "";
  int totalUsers = 0;
  int totalSecretCodes= 0;
  int votedCode1 = 0;
  int votedCode2 = 0;

  @override
  void initState() {
    super.initState();
    _userVotes = _fetchUserVotes();
    _userVotes.then((data) {
      setState(() {
        _allUserVotes = data;
        _filteredUserVotes = data;
      });
    });
    calculateStatistics();
  }

  Future<List<UserVoteData>> _fetchUserVotes() async {
    List<UserVoteData> userVotes = [];

    final userDocs = await FirebaseFirestore.instance.collection('Users').get();
    for (var userDoc in userDocs.docs) {
      String userId = userDoc.id;

      final voteDocs = await FirebaseFirestore.instance
          .collection('VoteList')
          .doc(userId)
          .collection('Vote')
          .get();

      for (var voteDoc in voteDocs.docs) {
        String? categoryName = await DatabaseMethods().getCategoryNameById(voteDoc['CategoryId']);
        String? username = await DatabaseMethods().getUserNameById(voteDoc['UserId']);
        final selectionDetails = await DatabaseMethods().getSelectionDetail(voteDoc['CategoryId'], voteDoc['SelectionId']);

        userVotes.add(
          UserVoteData(
            userName: username!,
            selection: categoryName!,
            selectionName:  selectionDetails['Name'],
            secretCode: voteDoc['SecretCode'],
          ),
        );
      }
    }
    return userVotes;
  }

  void _filterVotes(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        _filteredUserVotes = _allUserVotes;
      } else {
        _filteredUserVotes = _allUserVotes
            .where((vote) =>
                vote.userName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Widget buildStatRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  void calculateStatistics() async {
    final usersSnapshot = await DatabaseMethods().getAllUsers();
    final users = usersSnapshot.docs;

    int total = await DatabaseMethods().getNumberOfSecretCode();

    setState(() {
      totalUsers = users.length;
      votedCode1 = users.where((user) => user['Voted'] == 1).length;
      votedCode2 = users.where((user) => user['Voted'] == 2).length;
      totalSecretCodes = total;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Voting User Analytics",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
           // Statistics Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildStatRow("Total Users", totalUsers),
                    const Divider(),
                    buildStatRow("Total Secret Codes", totalSecretCodes),
                    const Divider(),
                    buildStatRow("Total Voted Users by 1 Secret Code", votedCode1),
                    const Divider(),
                    buildStatRow("Total Voted Users by 2 Secret Codes", votedCode2),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterVotes,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserVoteData>>(
              future: _userVotes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading data."));
                }
                if (_filteredUserVotes.isEmpty) {
                  return const Center(child: Text("No data available."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredUserVotes.length,
                  itemBuilder: (context, index) {
                    final userVote = _filteredUserVotes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          "User Name: ${userVote.userName}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Selection: ${userVote.selection}"),
                            Text("Selection Name: ${userVote.selectionName}"),
                            Text("Secret Code: ${userVote.secretCode}"),
                          ],
                        ),
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
}

class UserVoteData {
  final String userName;
  final String selection;
  final String selectionName;
  final String secretCode;

  UserVoteData({
    required this.userName,
    required this.selection,
    required this.selectionName,
    required this.secretCode,
  });
}
