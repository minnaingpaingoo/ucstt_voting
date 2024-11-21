import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImportWinnerResult extends StatefulWidget {
  const ImportWinnerResult({super.key});

  @override
  State<ImportWinnerResult> createState() => _ImportWinnerResultState();
}

class _ImportWinnerResultState extends State<ImportWinnerResult> {
  String? selectedCategory;
  String? selectedName;
  String? selectedTitle;
  String? selectedCategoryId;
  String? selectedCode;
  String? selectedImage;
  bool isSubmitting = false;

  final List<String> title = ['King', 'Queen', 'Prince', 'Princess'];

  List<Map<String, String>> categories = [];
  List<Map<String, String>> selections = []; // List to store all selection details

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndSetState();
  }

  // Fetch categories and set state
  Future<void> fetchCategoriesAndSetState() async {
    try {
      final fetchedCategories = await fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching categories: $e")),
      );
    }
  }
 

  Future<List<Map<String, String>>> fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Categories').orderBy('CategoryName').get();

      // Map documents to a list of maps with 'id' and 'name'
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Category ID
          'name': doc['CategoryName'] as String, // Category Name
        };
      }).toList();
    } catch (e) {
      throw Exception("Error fetching categories: $e");
    }
  }

  // Fetch list of names based on category
  Future<void> fetchNames(String categoryId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(categoryId)
          .collection('Selections')
          .orderBy('Code')
          .get();
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
         selections = snapshot.docs.map((doc) {
          return {
            'Name': doc['Name'] as String,
            'Code': doc['Code'] as String,
            'Image': doc['Image'] as String,
          };
        }).toList();

        selectedName = null; // Reset selected name when category changes
        selectedCode = null;
        selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching names: $e")),
      );
    }
  }

  // Save the winner to Firestore
  Future<void> saveWinner() async {
    if (selectedCategory == null || selectedName == null || selectedTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select category, name, and title", style: TextStyle(color: Colors.redAccent))),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // Simulate save process (replace with actual saving logic)
    await Future.delayed(const Duration(seconds: 2));

    try {
      await FirebaseFirestore.instance
          .collection('Winners')
          .doc(selectedTitle) // Use the category as the document ID
          .set({
            'Name': selectedName,
            'Code': selectedCode,
            'Image': selectedImage, //ID
            //Image
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Winner saved successfully!", style: TextStyle(color: Colors.greenAccent))),
      );

      // Reset the selections after successful submission
      setState(() {
        selectedCategory = null;
        selectedTitle = null;
        selectedName = null;
        selections = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving winner: $e")),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

   Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildDropdown<T>({
    required T? value,
    required String hint,
    required List<String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButton<T>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item as T,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
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
          "Import Winner Result",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle('Select Title'),
              buildDropdown<String>(
                value: selectedTitle,
                hint: 'Select Title',
                items: title,
                onChanged: (value) {
                  setState(() {
                    selectedTitle = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              buildSectionTitle('Select Category'),
              buildDropdown<String>(
                value: selectedCategory,
                hint: 'Select Category',
                items: categories.map((category) => category['name']!).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedCategoryId = categories.firstWhere((category) => category['name'] == value)['id'];
                    fetchNames(selectedCategoryId!);
                  });
                },
              ),
              const SizedBox(height: 16),

              buildSectionTitle('Select Winner Name'),
              if (selections.isEmpty)
                const Center(child: Text('No Winner Name Found'))
              else
                buildDropdown<String>(
                  value: selectedName,
                  hint: 'Select Winner Name',
                  items: selections.map((selection) => selection['Name']!).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedName = value;
                      final selected = selections.firstWhere((selection) => selection['Name'] == value);
                      selectedCode = selected['Code'];
                      selectedImage = selected['Image'];
                    });
                  },
                ),

              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : saveWinner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
