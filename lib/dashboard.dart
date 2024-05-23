import 'package:atreeon_datagrid_responsive/ReusableDataGridW.dart';
import 'package:atreeon_datagrid_responsive/sortFilterFields/models/Field.dart';
import 'package:atreeon_datagrid_responsive/sortFilterFields/models/FilterField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:genai_leaderboard/dashboard2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'participant.dart'; // Import the Participant model

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Participant> participants = [];
  bool isLoading = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchTerm = '';
  DateTime lastUpdated = DateTime.now();
  int totalCompletions = 0;

  void _fetchParticipants() async {
    print('Fetching participants');

    try {
      DocumentSnapshot updateLogSnapshot = await FirebaseFirestore.instance
          .collection('execution')
          .doc('update_log')
          .get();

      var lastUpdatedField =
          (updateLogSnapshot.data() as Map<String, dynamic>)['lastupdated'];
      print('lastUpdatedField: $lastUpdatedField');
      DateTime fetchedLastUpdated = (lastUpdatedField as Timestamp).toDate();
      print('fetchedLastUpdated: $fetchedLastUpdated');

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('user_data').get();
      List<Participant> fetchedParticipants = querySnapshot.docs
          .where((doc) => doc.data() != null)
          .map(
              (doc) => Participant.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      fetchedParticipants.sort((a, b) =>
          (b.totalCompletion ? 1 : 0).compareTo(a.totalCompletion ? 1 : 0));
      int fetchedTotalCompletions = fetchedParticipants
          .where((participant) => participant.totalCompletion == true)
          .length;

      if (mounted) {
        setState(() {
          isLoading = false;
          participants = fetchedParticipants;
          totalCompletions = fetchedTotalCompletions;
          lastUpdated = fetchedLastUpdated;
        });
      }
    } catch (e) {
      // Handle errors (e.g., network issues, data parsing errors)
      print('Error fetching participants: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          // Optionally, set an error message for the UI
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gen AI Study Jam Leaderboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        color: Colors.green,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Last Updated: ${lastUpdated.toString()}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.orange,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No of Completions: ${totalCompletions.toString()}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(18.0), // Add padding
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0), // Add padding
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey), // Add border
                          borderRadius: BorderRadius.circular(
                              12.0), // Add rounded corners
                        ),
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 600,
                          columns: const [
                            DataColumn2(
                              label: Text('Name'),
                              size: ColumnSize.L,
                            ),
                            DataColumn(
                              label: Text('Email'),
                            ),
                            DataColumn(
                              label: Text('Arcade'),
                            ),
                            DataColumn(
                              label: Text('Gen AI Apps'),
                            ),
                            DataColumn(
                              label: Text('Prompt Design'),
                            ),
                            DataColumn(
                              label: Text('Total Completion'),
                            ),
                            // Add more columns as needed
                          ],
                          rows: participants
                              .where((participant) => participant.name
                                  .toLowerCase()
                                  .contains(searchTerm.toLowerCase()))
                              .map((participant) {
                            return DataRow(
                              cells: [
                                DataCell(Text(participant.name)),
                                DataCell(Text(participant.email)),
                                DataCell(Text(participant.arcade
                                    ? 'Completed'
                                    : 'Not Completed')),
                                DataCell(Text(participant.genaiApps
                                    ? 'Completed'
                                    : 'Not Completed')),
                                DataCell(Text(participant.promptDesign
                                    ? 'Completed'
                                    : 'Not Completed')),
                                DataCell(Text(participant.totalCompletion
                                    ? 'Completed'
                                    : 'Not Completed')),
                                // Add more cells as needed
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
