import 'package:besodatahub/Models/jobfolge.dart';
import 'package:besodatahub/Widgets/Prebuilds/iconbutton.dart';
import 'package:besodatahub/Widgets/Prebuilds/textfield.dart'; // Import MyTextField
import 'package:besodatahub/Widgets/beso_prebuilds.dart';
import 'package:besodatahub/Widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'jobfolgen_edit.dart'; // Import the edit screen

class JobFolgenMainScreen extends StatefulWidget {
  const JobFolgenMainScreen({super.key});

  @override
  State<JobFolgenMainScreen> createState() => _JobFolgenMainScreenState();
}

class _JobFolgenMainScreenState extends State<JobFolgenMainScreen> {
  // Full list of JobFolgen
  final List<JobFolge> _allJobfolgen = [
    JobFolge(name: 'Jobfolge Alpha', jobs: []),
    JobFolge(name: 'Jobfolge Beta', jobs: []),
    JobFolge(name: 'Jobfolge Gamma', jobs: []),
  ];
  // Filtered list to display
  List<JobFolge> _filteredJobfolgen = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially, show all jobfolgen
    _filteredJobfolgen = List.from(_allJobfolgen);
    _searchController.addListener(_filterJobfolgen);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterJobfolgen);
    _searchController.dispose();
    super.dispose();
  }

  void _filterJobfolgen() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobfolgen = _allJobfolgen.where((jobfolge) {
        return jobfolge.name.toLowerCase().contains(query);
        // Add more fields to search if needed
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BesoAppBar(
        title: 'Jobfolgen Verwaltung',
        actions: [
          SearchField(
            ctrl: _searchController,
            enabled: true,
          ),
        ],
      ),
      body: ListView.builder(
        // ListView is the direct body
        itemCount: _filteredJobfolgen.length, // Use filtered list length
        itemBuilder: (context, index) {
          final jobFolge = _filteredJobfolgen[index]; // Use filtered list
          return BesoCard(
            // Using BesoCard for consistent styling
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobFolge.name, // Use correct variable name
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Removed beschreibung as it's not in the JobFolge model
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyIconButton(
                      icondata: Icons.edit_outlined,
                      tooltip: 'Bearbeiten',
                      onPressed: () {
                        // Navigate to Edit Screen, passing the current JobFolge
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                JobfolgenEditScreen(jobFolge: jobFolge),
                          ),
                        );
                      },
                    ),
                    MyIconButton(
                      icondata: Icons.visibility_outlined,
                      tooltip: 'Details',
                      onPressed: () {
                        // TODO: Implement Details functionality
                        print(
                            'Details Jobfolge: ${jobFolge.name}'); // Use name instead of id
                      },
                    ),
                    MyIconButton(
                      icondata: Icons.delete_outline,
                      tooltip: 'Löschen',
                      // iconColor: Theme.of(context).colorScheme.error, // Keep default color for now
                      onPressed: () {
                        // TODO: Implement Delete functionality
                        print(
                            'Delete Jobfolge: ${jobFolge.name}'); // Use name instead of id
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // FAB belongs to Scaffold
        tooltip: 'Neue Jobfolge hinzufügen',
        onPressed: () {
          // Navigate to Edit Screen without passing a JobFolge (for creation)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const JobfolgenEditScreen(), // Pass null or omit jobFolge
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
