import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _termsAndConditionsBody(),
    );
  }

  Widget _termsAndConditionsBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("1. Introduction"),
          const Text(
            "Welcome to UCSTT 2024-2025 King & Queen Selection Voting App. By using this app, you agree to comply with and be bound by the following terms and conditions.",
          ),
          const SizedBox(height: 20),
          _sectionTitle("2. User Responsibilities"),
          const Text(
            "Users must ensure that their actions while using the app comply with applicable laws. \nUsers must register with valid and accurate personal information to participate in the voting process. \nAny misuse of the app is prohibited. Each user is allowed only one account. \nMultiple accounts created to manipulate voting outcomes are not permitted. \nUsers must follow all rules and guidelines outlined for the voting process. \nUnauthorized attempts to interfere with or manipulate the voting system are strictly prohibited.",
          ),
          const SizedBox(height: 20),
          _sectionTitle("3. Privacy Policy"),
          const Text(
            "Your data is important to us. Please refer to our Privacy Policy for more details on how your data is managed.\nI value your privacy and am committed to protecting your personal information.",
          ),
          const Text("I use your data for the following purposes: \nTo facilitate the voting process and ensure accuracy. \nTo maintain app security and prevent fraud. \nTo analyze voting trends and improve app features. \nTo communicate important updates or changes to the voting process."),
          const SizedBox(height: 20),
          _sectionTitle("4. Limitation of Liability"),
          const Text(
            "I am not liable for any damages or losses that may arise from the use of the app.",
          ),
          const SizedBox(height: 20),
          _sectionTitle("5. Changes to Terms"),
          const Text(
            "I reserve the right to update these terms at any time. Changes will be effective immediately upon posting.",
          ),
          const SizedBox(height: 20),
          _sectionTitle("6. Contact Us"),
          const Text(
            "For questions or concerns regarding these terms, contact me at naingpaingoo@gmail.com.",
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }
}
