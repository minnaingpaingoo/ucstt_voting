import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ucstt_voting/services/database.dart';

class AddSelection extends StatefulWidget {
  const AddSelection({super.key});

  @override
  State<AddSelection> createState() => _AddSelectionState();
}

class _AddSelectionState extends State<AddSelection> {

  List<String> selection = [];
  String? value;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    getCategories(); // Fetch categories when the widget is initialized
  }

  Future<void> getCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('Categories').get();
      setState(() {
        selection = querySnapshot.docs.map((doc) => doc['CategoryName'] as String).toList();
      });
    } catch (e) {
      print("Error getting categories: $e");
    }
  }

  Future<void> getImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      } else {
        // The user canceled the picker, handle this case as needed
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }



  uploadItem() async{
    if(_formKey.currentState!.validate() && selectedImage!=null){
      
      var downloadUrl = await DatabaseMethods().uploadImageToCloudinary(selectedImage!);

      Map<String, dynamic> addSelection = {
        "Image": downloadUrl,
        "Name": nameController.text,
        "Code": codeController.text,
        "Details": detailsController.text,
        "isVisible": true,
        "Votes": 0,
      };

      String? categoryId = await DatabaseMethods().getCategoryIdByName(value!);

      await DatabaseMethods().addSelection(addSelection, categoryId!).then((value){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Selection has been added successfully!!",
              style: TextStyle(
                fontSize: 20,
                color: Colors.greenAccent,
              ),
            ),
          ),
        );
        nameController.clear();
        codeController.clear();
        detailsController.clear();
        selectedImage = null;
        setState(() {
          selectedImage = null;
          value = null;
        });
      });
    }
  }

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
          "Add Selection",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin:const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Upload the Selection Picture",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                selectedImage == null ?
                GestureDetector(
                  onTap: (){
                    getImage();
                  },
                  child: Center(
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ) :
                Center(
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  "Name",
                  style:TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter selection name' : null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Selection Name",
                      hintStyle: TextStyle(
                        fontSize:15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppin',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  "Code No",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.text,
                    validator: (value){
                       if (value == null || value.trim().isEmpty) {
                        return 'Please enter a Code Number';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Code Number",
                      hintStyle: TextStyle(
                        fontSize:15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppin',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                const Text(
                  "Info Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    maxLines: 6,
                    controller: detailsController,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter info details' : null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Info Details",
                      hintStyle: TextStyle(
                        fontSize:15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppin',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Select Category",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      items: selection
                      .map((item)=> DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      )).toList(),
                      onChanged: (value){
                        setState(() {
                          this.value = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a category' : null,
                      dropdownColor: Colors.white,
                      hint: const Text(
                        "Select Category",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                      value: value,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0,),
                GestureDetector(
                  onTap: (){
                    uploadItem();
                  },
                  child: Center(
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}