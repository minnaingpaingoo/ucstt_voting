import 'package:flutter/material.dart';
import 'package:ucstt_voting/admin/master_setting/generate_secret_code.dart';
import 'package:ucstt_voting/admin/master_setting/import_winner_result.dart';
import 'package:ucstt_voting/admin/master_setting/manage_winner_result.dart';
import 'package:ucstt_voting/admin/master_setting/secret_code_list.dart';
import 'package:ucstt_voting/admin/master_setting/view_all_selections_list.dart';
import 'package:ucstt_voting/admin/master_setting/voting_analytics.dart';
import 'package:ucstt_voting/services/database.dart';

class MasterSetting extends StatefulWidget {
  const MasterSetting({super.key});

  @override
  State<MasterSetting> createState() => _MasterSettingState();
}

class _MasterSettingState extends State<MasterSetting> {

  bool isVoteClosed= false;

  Future<void> fetchInitialVoteStatus() async {
  try {
    bool status = await DatabaseMethods().getCloseVoteStatus();
    setState(() {
      isVoteClosed = status; // Update the state with the fetched value
    });
  } catch (e) {
    print("Error fetching vote status: $e");
  }
}

  @override
  void initState() {
    super.initState();
    fetchInitialVoteStatus();
  }

  // Additional features can be added here
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
          "Master Setting",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Vote Toggle
            buildToggleFeature(
              icon: Icons.how_to_vote,
              title: "Close Vote",
              description:
                  "Enable or disable the voting system. If 'On,' users cannot cast votes.",
              value: isVoteClosed,
              onChanged: (value) async{
                setState(() {
                  isVoteClosed = value;
                });
                await DatabaseMethods().closeVote(isVoteClosed);
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.generating_tokens,
              title: "Generate Secret Code",
              description: "Generate Random Secret Code for voting in this system.",
              onTap: () {
                // Navigate to the generate secret code page
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GenerateSecretCode()));
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.token,
              title: "Secret Code List",
              description: "View secret code list and approval function by admin.",
              onTap: () {
                // Navigate to the secret code list
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SecretCodeList()));
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.analytics,
              title: "Voting User Analytics",
              description: "View voter participation and other metrics.",
              onTap: () {
                // Navigate to the user voting analytics page
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VotingAnalytics()));
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.list,
              title: "View All Selections List",
              description: "View selection vote count.",
              onTap: () {
                // Navigate to view all selections list
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewAllSelectionsList()));
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.import_contacts,
              title: "Import Winner Result",
              description: "Import King, Queen, Prince & Princess Result to show the user home page.",
              onTap: () {
                // Navigate to the import winnner result
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ImportWinnerResult()));
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.manage_history_outlined,
              title: "Manage Winner Result",
              description: "Manage King, Queen, Prince & Princess Result if have any problem.",
              onTap: () {
                // Navigate to the import winnner result
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageWinnerResult()));
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.security,
              title: "Manage Roles & Permissions",
              description: "Assign roles like admin or moderator to users.",
              onTap: () {
                // Navigate to roles & permissions management
              },
            ),
            const SizedBox(height: 20),

            buildActionFeature(
              icon: Icons.settings,
              title: "System Configuration",
              description: "Configure system-level settings for the voting system.",
              onTap: () {
                // Navigate to system configuration page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToggleFeature({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionFeature({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
