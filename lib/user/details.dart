import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ucstt_voting/services/database.dart';
import 'package:ucstt_voting/services/shared_pref.dart';

class Details extends StatefulWidget {
  final String categoryId, selectionId, image, name, details, code;

  const Details({
    super.key,
    required this.categoryId,
    required this.selectionId,
    required this.image,
    required this.name,
    required this.details,
    required this.code,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String? userId;
  bool isProcessing = false;
  bool isClose = false;

  @override
  void initState() {
    super.initState();
    loadUserId();
    fetchCloseStatus();
  }

  Future<void> loadUserId() async {
    userId = await SharedPreferenceHelper().getUserId();
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> showSecretCodeDialog(BuildContext context, TextEditingController controller) async {
    final formKey = GlobalKey<FormState>();
    bool isValid = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Secret Code"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter your secret code",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Secret code cannot be empty.";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                isValid = true;
                Navigator.of(context).pop();
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    return isValid;
  }


  Future<void> processVote(String secretCode) async {
    setState(() => isProcessing = true);
    try {
      final QuerySnapshot codeSnapshot = await DatabaseMethods().getSecretCode(secretCode);
      if (codeSnapshot.docs.isNotEmpty) {

        // Check the status of the secret code
        String? errorMessage;
        var secretCodeData = codeSnapshot.docs.first.data() as Map<String, dynamic>;
        String status = secretCodeData['Status'];

         if (status == 'Voted') {
          errorMessage = "Your Secret Code is already Voted.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 18))),
          );
        } else if(status == 'Pending'){
          errorMessage = "Your Secret Code is not confirmed. Contact to the admin";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 18))),
          );
        }
        else if (status == 'Done') {

          bool alreadyVoted = await DatabaseMethods().hasAlreadyVoted(userId!, widget.categoryId);
         
          if(alreadyVoted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("The Category has already been voted. Please try another.", style: TextStyle(color: Colors.redAccent, fontSize: 18)),
                duration: Duration(seconds: 2),
              ),
            );
          }else{
            final voteData = {
              "UserId": userId,
              "CategoryId": widget.categoryId,
              "SelectionId": widget.selectionId,
              "SecretCode": secretCode,
              "VotedAt": FieldValue.serverTimestamp(),
            };
            
            //Update and Save Data
            await DatabaseMethods().updateUserVoteCount(userId!);
            await DatabaseMethods().updateSecretCodeStatus(secretCode, "Voted");
            await DatabaseMethods().saveVoteData(userId!, voteData);
            await DatabaseMethods().updateVoteCount(widget.categoryId, widget.selectionId);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Your vote was submitted successfully!", style: TextStyle(color: Colors.green, fontSize: 18))),
            );
          }

        } else {
          errorMessage = "Invalid status for Secret Code.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 18))),
          );
        }
        return;
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid Secret Code", style: TextStyle(color: Colors.redAccent, fontSize: 18))),
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e", style: const TextStyle(color: Colors.redAccent))),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        ],
      ),
    );
  }

  Future<void> fetchCloseStatus() async {
    try {
     bool status = await DatabaseMethods().getCloseVoteStatus();
    setState(() {
      isClose = status; // Update the state with the fetched value
    });
    } catch (e) {
      print("Error fetching close status: $e");
    }
  }

  Widget buildVoteButton() {
    return ElevatedButton(
      onPressed: isProcessing || isClose
          ? null
          : () async {
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please Login first to vote.", style: TextStyle(color: Colors.redAccent, fontSize: 18))),
                );
                return;
              }
              final controller = TextEditingController();
              if (await showSecretCodeDialog(context, controller)) {
                await processVote(controller.text.trim());
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text( isClose ? "Voting Closed" : "Vote", style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(width: 10),
          const Icon(Icons.how_to_vote, color: Colors.white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.image,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 5),
              Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              buildInfoRow("Code No", widget.code),
              const Text("Information Details:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(widget.details, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Center(child: buildVoteButton()),
            ],
          ),
        ),
      ),
    );
  }
}
