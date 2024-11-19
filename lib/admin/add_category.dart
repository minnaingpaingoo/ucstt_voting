import 'package:flutter/material.dart';
import 'package:ucstt_voting/services/database.dart';
import 'package:ucstt_voting/widgets/widget_support.dart';
    
class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
 final _formKey = GlobalKey<FormState>();
  String? name;
  TextEditingController nameController = TextEditingController();

  Future<void> addCategory() async {
    try {
      await DatabaseMethods().addCategory(name!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Category added successfully!',
            style: TextStyle(
              color: Colors.greenAccent,
            ),
          ),
        ),
      );

      nameController.clear();
      setState(() {
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding category: $e',
            style: const TextStyle(
              color: Colors.redAccent,
            ),
          ),
        ),
      );
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
          "Add Category",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Form(
              key: _formKey,
              child: Container(
                margin:const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Category Name",
                      style: TextStyle(
                        fontSize:20,
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
                        color: const Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: nameController,
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Category Name",
                          hintStyle: AppWidget.lightTextFieldStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0,),
                    Center(
                      child: GestureDetector(
                        onTap:() async{
                          if(_formKey.currentState!.validate()){
                            name = nameController.text.trim();
                            await addCategory();
                          }
                        },
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.black12,
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
          ],
        ),
      ),
    );
  }
}