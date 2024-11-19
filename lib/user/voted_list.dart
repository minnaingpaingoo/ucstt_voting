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
      body: id == null
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : StreamBuilder(
        stream: DatabaseMethods().fetchVotedList(id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Voted List Found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final votedList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: votedList.length,
            itemBuilder: (context, index) {
              final vote = votedList[index].data();
              final voteId = votedList[index].id;
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
                    viewVotedListDetails(voteId, vote);
                  },
                ),
              );
            },
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
