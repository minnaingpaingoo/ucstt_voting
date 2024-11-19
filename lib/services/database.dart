import 'dart:io';
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // For http.MultipartRequest and MultipartFile
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods{

  Future addCategory(String name) async{
    return await FirebaseFirestore.instance.collection('Categories')
      .add({
        'CategoryName': name,
        'Created_At': FieldValue.serverTimestamp(),
      });
  }

  Future getNumberOfCategory() async{
    return await FirebaseFirestore.instance.collection('Categories').get();
  }

  Future getNumberOfUser() async{
    return await FirebaseFirestore.instance.collection('Users').get();
  }

  Future<int> getNumberOfSecretCode() async {
    final snapshot = await FirebaseFirestore.instance.collection('GenerateCode').get();
    return snapshot.docs.length; // Return the count of secret codes
  }

  Future<QuerySnapshot> getNumberOfVotedUser() async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .where('Voted', isEqualTo: 2)
        .get();
  }

  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    return FirebaseFirestore.instance.collection('Categories').orderBy('CategoryName').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'Id': doc.id,
            'Name': doc['CategoryName'],
          };
        }).toList();
      },
    );
  }

  Stream<List<Map<String, dynamic>>> getSelectionByCategory(String categoryId) {
    return FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .orderBy('Code')
      .snapshots()
      .map((snapshot){
        return snapshot.docs.map((doc) {
          return {
            'Id': doc.id,
            'Name': doc['Name'],
            'Code': doc['Code'],
            'Image': doc['Image'],
            'Details': doc['Details'],
            'isVisible': doc['isVisible']
          };
        }).toList();
      });
  }

  Future updateCategory(String categoryId, String categoryName) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .update({
        'CategoryName': categoryName,
    });
  }

  Future deleteCategory(String categoryId) async {
    return await FirebaseFirestore.instance
        .collection('Categories')
        .doc(categoryId)
        .delete();
  }

  Future<String?> getCategoryIdByName(String categoryName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .where('CategoryName', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // categoryId
    }
    return null; // If no category found
  }

  Future addSelection(Map<String, dynamic> userInfoMap, String categoryId) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .add(userInfoMap);
  }

  Future<List<Map<String, dynamic>>> getAllSelections() async {
    List<Map<String, dynamic>> allSelections = [];

    try {
      // Reference to the 'Categories' collection
      CollectionReference categoriesRef = FirebaseFirestore.instance.collection('Categories');

      // Fetch all 'CategoryId' documents
      QuerySnapshot categoriesSnapshot = await categoriesRef.get();

      for (QueryDocumentSnapshot categoryDoc in categoriesSnapshot.docs) {
        String categoryId = categoryDoc.id;

        // Reference to the 'Selections' collection under this 'CategoryId'
        CollectionReference selectionsRef = categoriesRef.doc(categoryId).collection('Selections');

        // Fetch all 'SelectionId' documents in the 'Selections' collection
        QuerySnapshot selectionsSnapshot = await selectionsRef.get();

        for (QueryDocumentSnapshot selectionDoc in selectionsSnapshot.docs) {
          // Add each selection with its category ID for context
          allSelections.add({
            'categoryId': categoryId,
            'selectionId': selectionDoc.id,
            'selectionData': selectionDoc.data(),
          });
        }
      }

      return allSelections;
    } catch (e) {
      print('Error fetching selections: $e');
      return [];
    }
  }

  Future getCategorySnapshot()async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .orderBy('CategoryName')
      .get();
  }

  Future getSelectionSnapshot(String categoryId) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .orderBy('Code')
      .get();
  }

  Future<void> updateSelectionVisibility(String categoryId, String selectionId, bool isVisible) async {
    await FirebaseFirestore.instance
        .collection('Categories')
        .doc(categoryId)
        .collection('Selections')
        .doc(selectionId)
        .update({'isVisible': isVisible});
  }

  Future<void> deleteSelection(String categoryId, String selectionId) async {
    await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .doc(selectionId)
      .delete();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('Categories').get();
    return snapshot.docs.map((doc) => {'CategoryId': doc.id, 'Name': doc['CategoryName']}).toList();
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const String cloudName = 'dq4rwikpu';
    const String uploadPreset = 'profile'; // Replace with your preset name
    final Uri url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      if (!imageFile.existsSync()) {
        print('Error: File does not exist.');
        return null;
      }

      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = jsonDecode(await response.stream.bytesToString());
        return responseData['secure_url']; // Image URL
      } else {
        var errorResponse = await response.stream.bytesToString();
        print('Error response: $errorResponse');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future updateSelection(String categoryId, String selectionId, String name, String code, String details, String imageUrl) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .doc(selectionId)
      .update({
        'Name': name,
        'Code': code,
        'Details': details,
        'Image': imageUrl,
      });
  }

  Stream<QuerySnapshot<Object?>> getTopFiveSelection(String categoryId){
    return FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .orderBy('Votes', descending: true)
      .limit(5)
      .snapshots();
  }

  Stream<QuerySnapshot<Object?>> getAllSelectionList(String categoryId){
    return FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .orderBy('Code')
      .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUsers() {
    return FirebaseFirestore.instance
      .collection('Users')
      .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return FirebaseFirestore.instance
      .collection('Users')
      .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchVotedList(String userId) {
    return FirebaseFirestore.instance
      .collection('VoteList')
      .doc(userId)
      .collection('Vote')
      .orderBy('SelectionCode')
      .snapshots();
  }

  Future addUserDetail(Map<String, dynamic> userInfoMap, String userId) async{
    return await FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .set(userInfoMap);
  }

  Future updateUserName(String userId, String name) async{
    return await FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .update({"Name": name});
  }

  Future updateUserClassName(String userId, String className) async{
    return await FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .update({"Class": className});
  }

  Future updateVoteCount(String categoryId, String selectionId) async{
    return await FirebaseFirestore.instance
      .collection('Categories')
      .doc(categoryId)
      .collection('Selections')
      .doc(selectionId)
      .update({
        'Votes': FieldValue.increment(1),
      });
  }

  Future<QuerySnapshot> getSecretCode(String secretCode) async{
    return await FirebaseFirestore.instance
      .collection('GenerateCode')
      .where(FieldPath.documentId, isEqualTo: secretCode) // Match document ID
      .get();
  }

  Future deleteSecretCode(String secretCode) async{
    return await FirebaseFirestore.instance
      .collection("GenerateCode")
      .doc(secretCode)
      .delete();
  }

  Stream<QuerySnapshot> getSecretCodeSnapshot(){
    return FirebaseFirestore.instance
      .collection('GenerateCode')
      .orderBy('Code')
      .snapshots();
  }

  Future updateSecretCodeStatus(String secretCode, String status) async{
    return await FirebaseFirestore.instance
      .collection('GenerateCode')
      .doc(secretCode)
      .update({
        'Status': status,
      });
  }

   Future updateUserVoteCount(String userId) async{
    return await FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .update({
        'Voted': FieldValue.increment(1),
      });
  }

  Future saveVoteData(String userId, Map<String, dynamic> voteData) async{
    return await FirebaseFirestore.instance
      .collection('VoteList')
      .doc(userId)
      .collection('Vote')
      .add(voteData);
  }

  Future getVotingList(String userId) async{
    return FirebaseFirestore.instance
      .collection('VoteList')
      .doc(userId)
      .collection('Vote')
      .get();
  }

  Future closeVote(bool status) async{
    return await FirebaseFirestore.instance
      .collection('CloseVote')
      .doc('close')
      .set({"Status": status});
  }

  Future<bool> getCloseVoteStatus() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('CloseVote')
        .doc('close')
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      return snapshot.data()?['Status'] ?? false; // Default to false if not found
    }

    return false; // Default to false if document doesn't exist
  }

 Future<String?> getCategoryNameById(String categoryId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(categoryId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['CategoryName']; // Replace 'name' with the field containing the category name in your database.
      } else {
        return null; // Document doesn't exist.
      }
    } catch (e) {
      print("Error fetching category name: $e");
      return null; // Handle error gracefully.
    }
  }

  Future<String?> getUserNameById(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['Name']; // Replace 'name' with the field containing the category name in your database.
      } else {
        return null; // Document doesn't exist.
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return null; // Handle error gracefully.
    }
  }

}