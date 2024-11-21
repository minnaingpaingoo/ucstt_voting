import 'package:flutter/material.dart';
import 'package:ucstt_voting/services/database.dart';
import 'package:ucstt_voting/services/shared_pref.dart';

class VotedList extends StatefulWidget {
  const VotedList({super.key});

  @override
  State<VotedList> createState() => _VotedListState();
}

class _VotedListState extends State<VotedList> {

  List<Map<String, dynamic>> votedItems = [];

  String? id;


  getthesharedpref() async{
    id= await SharedPreferenceHelper().getUserId();
    setState(() {
      
    });
  }

  ontheload() async{
    getthesharedpref();
    setState(() {
      
    });
  }
  @override
  void initState(){
    super.initState();
    ontheload();
    loadVotedItems();
  }

  Future<void> loadVotedItems() async {
    final userId = await SharedPreferenceHelper().getUserId();
    final snapshot = await DatabaseMethods().fetchVotedList(userId!).first;

    final List<Map<String, dynamic>> tempVotedItems = [];
    for (var doc in snapshot.docs) {
      final vote = doc.data();
      try {
        final selectionDetails = await DatabaseMethods()
            .getSelectionDetail(vote['CategoryId'], vote['SelectionId']);
        tempVotedItems.add({
          ...vote,
          'SelectionName': selectionDetails['Name'] ?? 'No Name',
          'SelectionImage': selectionDetails['Image'] ?? '',
          'SelectionCode': selectionDetails['Code'] ?? 'No Code',
        });
      } catch (e) {
        // Handle errors (e.g., document not found)
        tempVotedItems.add({
          ...vote,
          'SelectionName': 'Error fetching name',
          'SelectionImage': '',
          'SelectionCode': 'Error fetching code',
        });
      }
    }

    setState(() {
      votedItems = tempVotedItems;
    });
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
          "Your Voted List",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: votedItems.isEmpty
        ? const Center(child: Text("No vote list Found.", style: TextStyle(fontSize: 18)))
        : ListView.builder(
            itemCount: votedItems.length,
            itemBuilder: (context, index) {
              final vote = votedItems[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: vote['SelectionImage']!= null && vote['SelectionImage'].isNotEmpty
                    ? Image.network(
                        vote['SelectionImage']!,
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
                  ),
                  title: Text(
                    vote['SelectionName'] ?? 'No Name',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(vote['SelectionCode'] ?? 'No Code'),
                  onTap: () {
                    viewVotedListDetails(vote['SelectionId'], vote);
                  },
                ),
              );
            },
          ),
    );
  }

  // View user details function (can be modified based on requirements)
  void viewVotedListDetails(String voteId, Map<String, dynamic> vote) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(vote['SelectionName'] ?? 'No Name'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Code: ${vote['SelectionCode'] ?? 'No Code'}"),
                const SizedBox(height: 10),
                Text("Vote At: ${DateTime.parse(vote['VotedAt'].toDate().toString())}"),
                const SizedBox(height: 10),
                Text("Secret Code: ${vote['SecretCode'] ?? 'No Secret Code'}"),
                const SizedBox(height: 10),
                const Text("Profile Image:"),
                const SizedBox(height: 10),
                vote['SelectionImage']!= null && vote['SelectionImage'].isNotEmpty
                  ? Image.network(
                      vote['SelectionImage']!,
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
