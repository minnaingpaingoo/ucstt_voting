import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ucstt_voting/services/database.dart';
    
class ViewAllSelectionsList extends StatefulWidget {
  const ViewAllSelectionsList({super.key});

  @override
  State<ViewAllSelectionsList> createState() => _ViewAllSelectionsListState();
}

class _ViewAllSelectionsListState extends State<ViewAllSelectionsList> {

  Widget buildSelectionsList() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('Categories').orderBy('CategoryName').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var category = snapshot.data!.docs[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['CategoryName'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: DatabaseMethods().getAllSelectionList(category.id),
                  builder: (context, AsyncSnapshot<QuerySnapshot> selectionsSnapshot) {
                    if (!selectionsSnapshot.hasData) {
                      return const SizedBox();
                    }

                    return Column(
                      children: selectionsSnapshot.data!.docs.map((doc) {
                        return ListTile(
                          leading: Image.network(doc['Image'], width: 50),
                          title: Text(doc['Name']),
                          subtitle: Text('Votes: ${doc['Votes']}'),
                        );
                      }).toList(),
                    );
                  },
                ),
                const Divider(),
              ],
            );
          },
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
          "All Selections List",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSelectionsList(),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}