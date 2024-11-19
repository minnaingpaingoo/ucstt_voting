import 'package:flutter/material.dart';
import 'dart:async';

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

  final List<Map<String, String>> kingQueenSelection = [
    {"name": "Khun Yar Pyae", "image": "images/king.jpg"},
    {"name": "Yamone Htet", "image": "images/queen.jpg"},
  ];

  final List<Map<String, String>> princePrincessSelection = [
    {"name": "Nay Lin Oo", "image": "images/prince.jpg"},
    {"name": "Zin Wai Htun", "image": "images/princess.jpg"},
  ];

  final List<Map<String, String>> kingSelection = [
    {"name": "Khun Yar Pyae", "image": "images/king.jpg"},
    {"name": "Nay Lin Oo", "image": "images/prince.jpg"},
    {"name": "Seckyar Thurein Thee", "image": "images/seckyar_thurein_thee.jpg"},
    {"name": "Kaung Htet Thu", "image": "images/kaung_htet_thu.jpg"},
    {"name": "Nyam Htet", "image": "images/nyam_htet.jpg"},
    {"name": "Kyaw Zin Win", "image": "images/kyaw_zin_win.jpg"},
  ];

  final List<Map<String, String>> queenSelection = [
    {"name": "Yamone Htet", "image": "images/queen.jpg"},
    {"name": "Zin Wai Htun", "image": "images/princess.jpg"},
    {"name": "Htet Htet Yamin Oo", "image": "images/htet_htet_yamin_oo.jpg"},
    {"name": "Moe Moe Htet", "image": "images/moe_moe_htet.jpg"},
    {"name": "Nway Thuzar Hlaing", "image": "images/nway_thuzar_hlaing.jpg"},
    {"name": "Shoon Lei Phyu", "image": "images/shoon_lei_phyu.jpg"},
  ];

  final List<Map<String, String>> kingQueenPrincePrincessLastYear = [
    {"name": "King: Khun Yar Pyae", "image": "images/king.jpg"},
    {"name": "Queen: Yamone Htet", "image": "images/queen.jpg"},
    {"name": "Prince: Nay Lin Oo", "image": "images/prince.jpg"},
    {"name": "Princess: Zin Wai Htun", "image": "images/princess.jpg"},
  ]; 

  @override
  void initState() {
    super.initState();

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
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey,
          ),
          child: isRevealed
              ? Row(
                  children: [
                    Image.asset(
                      data[0]['image']!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data[0]['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    "?",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
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
              _bigCard(
                  "Prince & Princess", isPrincePrincessRevealed, princePrincessSelection),       
            ],
          ),
        ),
      ),
    );
  }
}
