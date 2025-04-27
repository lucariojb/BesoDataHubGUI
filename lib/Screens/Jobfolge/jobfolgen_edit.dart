import 'package:besodatahub/Models/job.dart';
import 'package:besodatahub/Models/jobfolge.dart';
import 'package:besodatahub/Models/konfig.dart'; // Import Konfig model
import 'package:besodatahub/Widgets/Prebuilds/expansiontile.dart'; // Import MyExpansionTile
import 'package:besodatahub/Widgets/Prebuilds/iconbutton.dart';
import 'package:besodatahub/Widgets/beso_prebuilds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/data_service.dart';
import '../../Models/konnektor.dart';
import 'add_job_popup.dart';

class JobfolgenEditScreen extends StatefulWidget {
  final JobFolge? jobFolge; // Nullable for creating a new JobFolge

  const JobfolgenEditScreen({super.key, this.jobFolge});

  @override
  State<JobfolgenEditScreen> createState() => _JobfolgenEditScreenState();
}

class _JobfolgenEditScreenState extends State<JobfolgenEditScreen> {
  //
  late final DataService dataService;

  late JobFolge _editableJobFolge;
  late String _appBarTitle;
  late List<Job> _jobs; // Local list for reordering

  @override
  void initState() {
    //Init DataService
    dataService = context.read<DataService>();

    super.initState();
    if (widget.jobFolge == null) {
      initNewForm(); // Create a new JobFolge
    } else {
      initEditForm();
    }
    _jobs = _editableJobFolge.jobs; // Initialize local list
  }

  void initNewForm() {
    // Creating a new JobFolge
    _appBarTitle = 'Neue Jobfolge erstellen';
    // Initialize with a default name or prompt user later
    _editableJobFolge = JobFolge(name: 'Neue Jobfolge', jobs: []);
  }

  void initEditForm() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BesoAppBar(
        title: _appBarTitle,
        actions: [
          MyIconButton(
            icondata: Icons.save_outlined,
            tooltip: 'Speichern',
            onPressed: _saveJobFolge,
          )
        ],
      ),
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.all(8.0),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          // Use job.hashCode or a unique ID if available for the Key
          // Using ValueKey with index for simplicity here, but prefer unique ID
          final cardKey = ValueKey('job_card_$index');

          // Use MyExpansionTile instead of BesoCard
          return MyExpansionTile(
            key: cardKey, // Key is crucial for ReorderableListView
            outsidePadding:
                const EdgeInsets.symmetric(vertical: 4.0), // Use outsidePadding
            tilePadding: const EdgeInsets.symmetric(
                horizontal: 8.0), // Adjust tile padding
            // Drag handle as leading widget
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            // Job details in the title
            title:
                Text(job.name, style: Theme.of(context).textTheme.titleSmall),
            subtitle: Text('Konnektor: ${job.konnektor}',
                style: Theme.of(context).textTheme.bodySmall),
            // Action buttons as trailing widget
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyIconButton(
                  icondata: Icons.edit_note,
                  tooltip: 'Job bearbeiten',
                  onPressed: () {
                    // TODO: Implement Job edit functionality
                    print('Edit Job: ${job.name}'); // Use 'name'
                  },
                ),
                MyIconButton(
                  icondata: Icons.delete_sweep_outlined,
                  tooltip: 'Job entfernen',
                  iconColor: Theme.of(context).colorScheme.error,
                  onPressed: () {
                    setState(() {
                      _jobs.removeAt(index);
                      _editableJobFolge.jobs = _jobs;
                    });
                    print('Remove Job: ${job.name}'); // Use 'name'
                  },
                ),
              ],
            ),
            // Display Konfigs as children when expanded
            children: _buildKonfigList(job),
          );
        },
        onReorder: _onReorder,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Neuen Job hinzufügen',
        onPressed: _addJob,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildKonfigList(Job job) {
    return job.konfig.map((konfig) {
      return ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.only(left: 40.0, right: 16.0), // Indent children
        title: Text(konfig.name, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text('Wert: ${konfig.value}',
            style: Theme.of(context).textTheme.bodySmall),
        // TODO: Add editing capability for Konfig values later
      );
    }).toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Job item = _jobs.removeAt(oldIndex);
      _jobs.insert(newIndex, item);
      _editableJobFolge.jobs = _jobs; // Update the main object
    });
  }

  void _addJob() async {
    // Show AddJobPopup to init new Job
    Map<String, dynamic>? result = await showDialog(
        context: context, builder: (context) => const AddJobPopup());

    if (result == null) return; // User canceled or no data returned

    String jobName = result['Name'];
    String konnektorName = result['Konnektor'];

    // Load Full Konnektor
    Konnektor konnektor =
        await dataService.loadKonnektorFromName(konnektorName);

    // Load Konfigdata for Job
    List<Konfig> jobKonfigs =
        await dataService.loadKonfigsForJob(konnektor.exec.name);

    _jobs.add(Job(
      name: jobName,
      konnektor: konnektorName,
      konfig: jobKonfigs,
      overrideKonnektorKonfig: konnektor.konfig,
    ));

    setState(() {});
  }

  void _saveJobFolge() {
    // TODO: Implement save logic (e.g., call DataService)
    print('Save JobFolge: ${_editableJobFolge.name}');
    print(
        'Jobs: ${_editableJobFolge.jobs.map((j) => j.name).toList()}'); // Use 'name'
    Navigator.of(context).pop(); // Go back after saving (or attempting to)
  }
}
