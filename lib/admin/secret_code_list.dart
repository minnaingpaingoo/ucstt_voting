import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ucstt_voting/services/database.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SecretCodeList extends StatefulWidget {
  const SecretCodeList({super.key});

  @override
  State<SecretCodeList> createState() => _SecretCodeListState();
}

class _SecretCodeListState extends State<SecretCodeList> {
  final ScrollController _scrollController = ScrollController();
  int totalCodes = 0;
  int totalVoted = 0;
  int totalDone = 0;
  int totalPending = 0;

  @override
  void initState() {
    super.initState();
    _getCodeStats();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCodeStats() async {
    try {
      // Get the counts for each status
      QuerySnapshot allCodesSnapshot =
          await FirebaseFirestore.instance.collection('GenerateCode').get();

      QuerySnapshot votedCodesSnapshot = await FirebaseFirestore.instance
          .collection('GenerateCode')
          .where('Status', isEqualTo: 'Voted')
          .get();

      QuerySnapshot doneCodesSnapshot = await FirebaseFirestore.instance
          .collection('GenerateCode')
          .where('Status', isEqualTo: 'Done')
          .get();

      QuerySnapshot pendingCodesSnapshot = await FirebaseFirestore.instance
          .collection('GenerateCode')
          .where('Status', isEqualTo: 'Pending')
          .get();

      // Update state with totals
      setState(() {
        totalCodes = allCodesSnapshot.docs.length;
        totalVoted = votedCodesSnapshot.docs.length;
        totalDone = doneCodesSnapshot.docs.length;
        totalPending = pendingCodesSnapshot.docs.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stats: $e')),
      );
    }
  }

  Future<void> printAllSecretCodes() async {
    try {
      // Fetch all secret codes
      final querySnapshot = await FirebaseFirestore.instance.collection('GenerateCode').get();
      final secretCodes = querySnapshot.docs;

      if (secretCodes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No secret codes available to print.'),
          ),
        );
        return;
      }

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Secret Code List",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.ListView.builder(
                itemCount: secretCodes.length,
                itemBuilder: (context, index) {
                  final codeData = secretCodes[index].data();
                  final secretCode = secretCodes[index].id;

                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Text(
                      "Code: $secretCode\n"
                      "Status: ${codeData['Status'] ?? 'Unknown'}\n",
                      style: const pw.TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );

      // Show print dialog
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error printing secret codes: $e'),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secret Code List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Dashboard section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatRow("Total Secret Codes", totalCodes),
                    const Divider(),
                    _buildStatRow("Total Voted", totalVoted),
                    const Divider(),
                    _buildStatRow("Total Done", totalDone),
                    const Divider(),
                    _buildStatRow("Total Pending", totalPending),
                  ],
                ),
              ),
            ),
          ),

          //Print Button To Print The Secret Code 
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text("Print Secret Codes"),
              onPressed: printAllSecretCodes, // Call the function
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          // List of secret codes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseMethods().getSecretCodeSnapshot(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading secret codes."));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No secret codes available."));
                }

                final codes = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: codes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final codeData =
                        codes[index].data() as Map<String, dynamic>;
                    final secretCode = codes[index].id;

                    return _buildSecretCodeCard(secretCode, codeData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSecretCodeCard(String secretCode, Map<String, dynamic> codeData) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          secretCode,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              codeData['CreatedAt'] != null
                  ? "Generated on: ${DateTime.parse(codeData['CreatedAt'].toDate().toString())}"
                  : "Generated on: Unknown",
            ),
            const SizedBox(height: 5),
            Text(
              codeData['Status'] != null
                  ? "Status: ${codeData['Status']}"
                  : "Status: Unknown",
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (codeData['Status'] == "Pending")
              TextButton(
                onPressed: () async {
                  await _updateStatus(secretCode, "Done");
                  setState(() {
                    _getCodeStats();
                  });
                },
                child: const Text(
                  "Mark Done",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            if (codeData['Status'] == "Done")
              const Text(
                "Done",
                style: TextStyle(color: Colors.greenAccent, fontSize: 16),
              ),
            if (codeData['Status'] == "Voted")
              const Text(
                "Voted",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _deleteCode(secretCode);
                _getCodeStats();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String secretCode, String status) async {
    try {
      await DatabaseMethods().updateSecretCodeStatus(secretCode, status);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _deleteCode(String secretCode) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this secret code?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        await DatabaseMethods().deleteSecretCode(secretCode);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Secret code deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting secret code: $e')),
        );
      }
    }
  }
}
