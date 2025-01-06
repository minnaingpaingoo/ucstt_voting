import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ucstt_voting/services/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isKingQueenRevealed = false; // Toggle for King & Queen results
  bool isPrincePrincessRevealed = false; // Toggle for Prince & Princess results
  late PageController kingController;
  late PageController queenController;
  late PageController kingQueenPrincePrincessLastYearController;
  late Timer kingTimer;
  late Timer queenTimer;
  late Timer kingQueenPrincePrincessLastYearTimer;
  int kingPage = 0;
  int queenPage = 0;
  int kingQueenPrincePrincessLastYearPage = 0;
  String? name;

  final List<Map<String, String>> kingQueenSelection = [];

  final List<Map<String, String>> princePrincessSelection =[];

  final List<Map<String, String>> kingSelection = [
    {"name": "KS1: Sai Aung Nay Thu", "image": "images/KS_1 Sai Aung Nay Thu.jpg"},
    {"name": "KS2: Aung Zin Phyo", "image": "images/KS_2 Aung Zin Phyo.jpg"},
    {"name": "KS3: Yair Linn Aung", "image": "images/KS_3 Yair Linn Aung.jpg"},
    {"name": "KS4: Paing Khant Thu", "image": "images/KS_4 Paing Khant Thu.jpg"},
    {"name": "KS5: Shine Linn Htet", "image": "images/KS_5 Shine Linn Htet.jpg"},
    {"name": "KS6: Htun Win Aye", "image": "images/KS_6 Htun Win Aye.jpg"},
    {"name": "KS7: Lin Khant Ko", "image": "images/KS_7 Lin Khant Ko.jpg"},
    {"name": "KS8: Lin Khant Thu", "image": "images/KS_8 Lin Khant Thu.jpg"},
  ];

  final List<Map<String, String>> queenSelection = [
    {"name": "QS1: Yadanar Aung", "image": "images/QS_1 Yadanar Aung.jpg"},
    {"name": "QS2: Su Pone Chit", "image": "images/QS_2 Su Pone Chit.jpg"},
    {"name": "QS3: Pwint Yamone Zaw", "image": "images/QS_3 Pwint Yamone Zaw.jpg"},
    {"name": "QS4: Aie Thar Khu", "image": "images/QS_4 Aie Thar Khu.jpg"},
    {"name": "QS5: Thet Htar Su", "image": "images/QS_5 Thet Htar Su.jpg"},
    {"name": "QS6: Han Chi Htet", "image": "images/QS_6 Han Chi Htet.jpg"},
    {"name": "QS7: Hnin Yu Yu Lwin", "image": "images/QS_7 Hnin Yu Yu Lwin.jpg"},
    {"name": "QS8: Hsu Myat Naing", "image": "images/QS_8 Hsu Myat Naing.jpg"},
  ];

  final List<Map<String, String>> kingQueenPrincePrincessLastYear = [
    {"name": "King: Khun Yar Pyae", "image": "images/king.jpg"},
    {"name": "Queen: Yamone Htet", "image": "images/queen.jpg"},
    {"name": "Prince: Nay Lin Oo", "image": "images/prince.jpg"},
    {"name": "Princess: Zin Wai Htun", "image": "images/princess.jpg"},
  ]; 

  sharedpref() async{
    name = await SharedPreferenceHelper().getUserName();
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    sharedpref();
    fetchWinners();

    kingController = PageController(initialPage: 0);
    queenController = PageController(initialPage: 0);
    kingQueenPrincePrincessLastYearController = PageController(initialPage: 0);

    kingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        kingPage = (kingPage + 1) % kingSelection.length;
        kingController.animateToPage(
          kingPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });

    queenTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        queenPage = (queenPage + 1) % queenSelection.length;
        queenController.animateToPage(
          queenPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });

    kingQueenPrincePrincessLastYearTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        kingQueenPrincePrincessLastYearPage = (kingQueenPrincePrincessLastYearPage + 1) % kingQueenPrincePrincessLastYear.length;
        kingQueenPrincePrincessLastYearController.animateToPage(
          kingQueenPrincePrincessLastYearPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    kingController.dispose();
    queenController.dispose();
    kingQueenPrincePrincessLastYearController.dispose();
    kingTimer.cancel();
    queenTimer.cancel();
    kingQueenPrincePrincessLastYearTimer.cancel();
    super.dispose();
  }

  Future<void> fetchWinners() async {
    try {
      // Fetch the King and Queen data
      DocumentSnapshot kingDoc = await FirebaseFirestore.instance.collection('Winners').doc('King').get();
      DocumentSnapshot queenDoc = await FirebaseFirestore.instance.collection('Winners').doc('Queen').get();

      if (kingDoc.exists) {
        kingQueenSelection.add({
          "name": "King: ${kingDoc['Name']}",
          "image": kingDoc['Image'],
        });
      }
      if (queenDoc.exists) {
        kingQueenSelection.add({
          "name": "Queen: ${queenDoc['Name']}",
          "image": queenDoc['Image'],
        });
      }

      // Fetch the Prince and Princess data
      DocumentSnapshot princeDoc = await FirebaseFirestore.instance.collection('Winners').doc('Prince').get();
      DocumentSnapshot princessDoc = await FirebaseFirestore.instance.collection('Winners').doc('Princess').get();

      if (princeDoc.exists) {
        princePrincessSelection.add({
          "name": "Prince: ${princeDoc['Name']}",
          "image": princeDoc['Image'],
        });
      }
      if (princessDoc.exists) {
        princePrincessSelection.add({
          "name": "Princess: ${princessDoc['Name']}",
          "image": princessDoc['Image'],
        });
      }
    } catch (e) {
      print("Error fetching winners: $e");
    }
  }

  Widget _bigCard(String title, bool isRevealed, List<Map<String, String>> data) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isRevealed = !isRevealed;
        });
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
          ),
          child: !isRevealed && data.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title at the top
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Images row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.network(
                            item['image']!,
                            height: 130,
                            width: 130,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Names at the bottom
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            item['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    "?",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
        ),
      ),
    );
  }



  Widget _slider(List<Map<String, String>> selection, PageController controller) {
    return SizedBox(
      height: 500,
      child: PageView.builder(
        controller: controller,
        itemCount: selection.length,
        itemBuilder: (context, index) {
          final item = selection[index];
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 5,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item['image']!,
                    height: 430,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget developerAddress() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10), // Rounded corners for the card
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Developed by: Min Naing Paing Oo",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, // Text color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Contact: naingpaingoo@gmail.com",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, // Text color
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "King, Queen, Prince & Princess\n               (2023-2024)",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _slider(kingQueenPrincePrincessLastYear, kingQueenPrincePrincessLastYearController),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "2024-2025 King Selections",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _slider(kingSelection, kingController),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "2024-2025 Queen Selections",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _slider(queenSelection, queenController),
              const SizedBox(height: 20),
              const Text(
                "Who will be 2024-2025 King & 2024-2025 Queen?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _bigCard("King & Queen", isKingQueenRevealed, kingQueenSelection),
              const SizedBox(height: 20),
              const Text(
                "Who will be 2024-2025 Prince & 2024-2025 Princess?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _bigCard("Prince & Princess", isPrincePrincessRevealed, princePrincessSelection),
              if(name == null)
                developerAddress(),     
            ],
          ),
        ),
      ),
    );
  }
}
