import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GenerateSecretCode extends StatefulWidget {
  const GenerateSecretCode({super.key});

  @override
  State<GenerateSecretCode> createState() => _GenerateSecretCodeState();
}

class _GenerateSecretCodeState extends State<GenerateSecretCode> {
  final TextEditingController _numberController = TextEditingController();
  bool _isLoading = false;

  // Function to generate a random secret code
  String _generateRandomCode(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  // Function to generate and store secret codes
  Future<void> _generateAndStoreCodes(int count) async {
    setState(() {
      _isLoading = true;
    });

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (int i = 0; i < count; i++) {
        String code = _generateRandomCode(8); // Generate an 8-character code
        DocumentReference docRef =FirebaseFirestore.instance
          .collection('GenerateCode')
          .doc(code);
          batch.set(
            docRef, 
            {'Code': code,
            'Status': 'Pending',
            'CreatedAt': FieldValue.serverTimestamp(),
            }
          );
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$count codes generated and stored successfully!',
            style: const TextStyle(color: Colors.green),
          ),
        ),
      );

      _numberController.clear();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
          "Generate Secret Code",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the number of codes to generate:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter number between 1 to 100',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        String input = _numberController.text.trim();
                        if (input.isEmpty || int.tryParse(input) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid number.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                          return;
                        }

                        int count = int.parse(input);
                        if (count <= 0 || count>=100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Number must be greater than 0 or no more than 100.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                          return;
                        }

                        _generateAndStoreCodes(count);
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Generate"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
