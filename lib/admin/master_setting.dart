import 'package:flutter/material.dart';

class MasterSetting extends StatefulWidget {
  const MasterSetting({super.key});

  @override
  State<MasterSetting> createState() => _MasterSettingState();
}

class _MasterSettingState extends State<MasterSetting> {
  bool isVoteClosed = false; // Tracks the status of the voting system

  // Additional features can be added here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Setting'),
        centerTitle: true,
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
              onChanged: (value) {
                setState(() {
                  isVoteClosed = value;
                  // Save the setting to a database if required
                  // Example: DatabaseMethods().updateVoteStatus(value);
                });
              },
            ),
            const SizedBox(height: 20),

            // Placeholder for other features
            buildActionFeature(
              icon: Icons.analytics,
              title: "View Voting Analytics",
              description: "Analyze voter participation and other metrics.",
              onTap: () {
                // Navigate to the analytics page
                // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsPage()));
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
