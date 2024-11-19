import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ucstt_voting/services/database.dart';

class ManageSelection extends StatefulWidget {
  const ManageSelection({super.key});

  @override
  State<ManageSelection> createState() => _ManageSelectionState();
}

class _ManageSelectionState extends State<ManageSelection> {
 
  List<Map<String, dynamic>> selection = [];

  File? newImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchAllSelection();
  }

  Future<void> fetchAllSelection() async {

    QuerySnapshot categoriesSnapshot = await DatabaseMethods().getCategorySnapshot();

    List<Map<String, dynamic>> items = [];

    for (var category in categoriesSnapshot.docs) {

      String categoryId = category.id;

      QuerySnapshot selectionSnapshot = await DatabaseMethods().getSelectionSnapshot(categoryId);

      for (var selectionList in selectionSnapshot.docs) {
        var selectionData = selectionList.data() as Map<String, dynamic>;
        selectionData['selectionId'] = selectionList.id;
        selectionData['categoryId'] = categoryId;
        items.add(selectionData);
      }
    }

    setState(() {
      selection = items;
    });
  }

  Future<void> toggleVisibility(String categoryId, String selectionId, bool currentVisibility) async {
    await DatabaseMethods().updateSelectionVisibility(categoryId, selectionId, !currentVisibility);
    fetchAllSelection(); // Refresh after update
  }

  // Function to delete a food item
  Future<void> deleteFoodItem(String categoryId, String selectionId) async {
    await DatabaseMethods().deleteSelection(categoryId, selectionId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Selection is deleted successfully!",
          style: TextStyle(color: Colors.greenAccent),
        ),
      ),
    );
    fetchAllSelection(); // Refresh after deletion
  }

  Future<void> getImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          newImageFile = File(image.path);
        });
      } else {
        // The user canceled the picker, handle this case as needed
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }


  // Function to edit a food item (name and price here for simplicity)
  void editSelection(Map<String, dynamic> selection) {
    final rootContext = context;
    final formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController(text: selection['Name']);
    TextEditingController codeController = TextEditingController(text: selection['Code'].toString());
    TextEditingController detailController = TextEditingController(text: selection['Details'].toString());
    
    String? selectedCategoryId = selection['categoryId'];
    String? selectedImageUrl = selection['Image'];

    newImageFile = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Selection'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  // Code Field
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Code'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter selection code';
                      }
                      return null;
                    },
                  ),
                  // Details Field
                  TextFormField(
                    controller: detailController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Info Details'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter info details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category Dropdown
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseMethods().getCategories(), // Fetch categories
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final categories = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        items: categories.map<DropdownMenuItem<String>>((category) { // Explicitly specify the type
                          return DropdownMenuItem<String>(
                            value: category['CategoryId'],
                            child: Text(category['Name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCategoryId = value;
                        },
                        decoration: const InputDecoration(labelText: 'Category'),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Center(child: Text("Tap the Image to change Picture.", style: TextStyle(color: Colors.redAccent))),
                  const SizedBox(height: 16),
                  // Image Picker
                  GestureDetector(
                    onTap: (){
                      getImage();
                      setState(() {
                        
                      });
                    },
                    child: newImageFile != null
                        ? Image.file(
                          newImageFile!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover
                        )
                        : selectedImageUrl!= null
                            ? Image.network(selectedImageUrl!, width: 100, height: 100, fit: BoxFit.cover)
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.camera_alt, size: 50),
                              ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  
                  String? newImageUrl = selectedImageUrl;

                  if (newImageFile != null) {
                    // Upload the new image and get its URL
                    newImageUrl = await DatabaseMethods().uploadImageToCloudinary(newImageFile!);
                  }

                  // Update food item in Firestore
                  await DatabaseMethods().updateSelection(
                    selectedCategoryId!,
                    selection['selectionId'],
                    nameController.text.trim(),
                    codeController.text.trim(),
                    detailController.text.trim(),
                    newImageUrl!,
                  );

                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Selection is updated successfully!",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                  
                  nameController.clear();
                  codeController.clear();
                  detailController.clear();
                  selectedCategoryId = "";
                  selectedImageUrl= "";
                  
                  fetchAllSelection(); // Refresh after update
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
          "Manage Selection",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: 
      selection.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: selection.length,
            itemBuilder: (context, index) {
              var selections = selection[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Material(
                  //color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.2),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: selections['Image'] != null
                      ? Image.network(
                          selections['Image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 60),
                    title: Text(
                      selections['Name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${selections['Code']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: selections['isVisible'] ?? true,
                          onChanged: (value) {
                            toggleVisibility(selections['categoryId'], selections['selectionId'], selections['isVisible'] ?? true);
                          },
                          activeColor: Colors.green,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editSelection(selections),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirmDeleteSelection = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Delete Selection"),
                                  content: const Text("Are you sure you want to delete this selection?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Yes"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDeleteSelection) {
                              deleteFoodItem(selections['categoryId'], selections['selectionId']);
                            }
                          },
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
}
