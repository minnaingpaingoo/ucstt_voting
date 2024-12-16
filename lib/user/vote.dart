import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ucstt_voting/services/database.dart';
import 'package:ucstt_voting/user/details.dart';
    
class Vote extends StatefulWidget {
  const Vote({super.key});

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> {

  bool isDarkMode = false;

  String? selectedCategory;

  String? name;

  String? selectedCategoryId;

  Stream<List<Map<String, dynamic>>>? selectionStream;

  getthesharepref()async{
    //name = await SharedPreferenceHelper().getUserName();
    if (mounted) {
      setState(() {});
    }
  }

    ontheload() async {
    await getthesharepref();

    var firstCategorySnapshot = await FirebaseFirestore.instance
      .collection('Categories')
      .orderBy('CategoryName')
      .limit(1)
      .get();

    if (firstCategorySnapshot.docs.isNotEmpty) {
      // Set selectedCategory and load the food items for this category
      var firstCategory = firstCategorySnapshot.docs.first.data();
      selectedCategory = firstCategory['CategoryName'];
      selectionStream = DatabaseMethods().getSelectionByCategory(firstCategorySnapshot.docs.first.id);
      selectedCategoryId = firstCategorySnapshot.docs.first.id;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState(){
    ontheload();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget showSelectionBtn() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseMethods().getCategoriesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Categories Found"));
        }

        var categories = snapshot.data!;
        return Row(
          children: categories.map((category) {
            bool isSelected = category['Name'] == selectedCategory; // Track selected category
        
            return GestureDetector(
              onTap: () async {
                setState(() {
                  selectedCategory = category['Name'];
                });
                selectionStream = DatabaseMethods().getSelectionByCategory(category['Id']);
                selectedCategoryId = category['Id'];
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Material(
                  elevation: isSelected ? 5 : 2,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text(
                      category['Name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget showAllSelection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: selectionStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Selection Found"));
        }

        // Filter items where isVisible is true
        var items = snapshot.data!.where((item) => item['isVisible'] == true).toList();
        if(items.length < 0){
          return const Center(child: Text("No Selection Found"));
        }else{
          return SizedBox(
            height: 450,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 10),
              itemCount: items.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                var item = items[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          categoryId: selectedCategoryId!,
                          selectionId: item['Id'],
                          details: item['Details'],
                          name: item['Name'],
                          code: item['Code'],
                          image: item['Image'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              item['Image'],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  item['Name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold, 
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  'Code No: '+ item['Code'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold, 
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }  
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        //color: isDarkMode ? Colors.white : Colors.black12,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection Categories
              const Center(
                child: Text(
                  'Vote Your Favourite',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              showSelectionBtn(),
              const SizedBox(height: 10),
              if (selectedCategory != null) ...[
                Center(
                  child: Text(
                    selectedCategory!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Center(
                  child: Text(
                    'Please choose Only ONE your favourite',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
              if (selectedCategory != null)
                showAllSelection()
              else
                const Center(
                  child: Text(
                    "No Selection Found.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}