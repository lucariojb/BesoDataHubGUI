import 'package:besodatahub/Models/data_service.dart';
import 'package:besodatahub/Models/exec.dart';
import 'package:besodatahub/Models/konfig.dart';
import 'package:besodatahub/Models/konnektor.dart';
import 'package:besodatahub/Provider/edit_state.dart';
import 'package:besodatahub/Screens/KonnektorKonfiguration/dialog_select_exec.dart';
import 'package:besodatahub/Screens/KonnektorKonfiguration/konnektor_konfiguration_line.dart';
import 'package:besodatahub/Widgets/beso_prebuilds.dart';
import 'package:besodatahub/Widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class KonnektorKonfiguration extends StatefulWidget {
  const KonnektorKonfiguration({super.key});

  @override
  State<KonnektorKonfiguration> createState() => _KonnektorKonfigurationState();
}

class _KonnektorKonfigurationState extends State<KonnektorKonfiguration> {
  final List<Konnektor> _konnektoren = [];

  List<ExecDefinition> execs = [];
  final TextEditingController _ctrlSearch = TextEditingController();
  late final DataService dataService;
  @override
  void initState() {
    dataService = context.read<DataService>();
    super.initState();
    loadData();
    initSearchField();
  }

  void loadData() async {
    dataService.loadKonnektorOverview().then((konnektoren) {
      setState(() {
        _konnektoren.addAll(konnektoren.where((e) => e.exec.path.isNotEmpty));
      });
    });
  }

  void initSearchField() {
    _ctrlSearch.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final editState = context.watch<EditState>();
    return Scaffold(
        appBar: BesoAppBar(
          title: 'Konnektor Konfiguration',
          actions: [
            SearchField(
                enabled: !editState.isCurrentLineEditDirty, ctrl: _ctrlSearch)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => addNewKonnektor(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: 90.w,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _konnektoren.length,
                    itemBuilder: (context, index) {
                      final konnektor = _konnektoren[index];
                      return KonnektorKonfigurationLine(
                        index: index,
                        konnektor: konnektor,
                        isEditing: editState.currentlyEditingIndex == index,
                        onEditStart: () {},
                        onSave: (konfig) {},
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void addNewKonnektor() async {
    //Check if a Konnektor is currently being edited
    final editState = context.read<EditState>();
    if (editState.isCurrentLineEditDirty) {
      print("Blocked: Cannot add new konnektor while editing.");
      return;
    }
    //Select Exec
    Konnektor? newKonnektor = await showDialog<Konnektor?>(
        context: context, builder: (context) => const SelectExecDialog());
    //Cancel Process if nothing is selected
    if (newKonnektor == null) {
      return;
    }
    //Make Konnektor editable
    List<String> konfigSchluessel = await dataService
        .loadKonfigSchluesselForKonnektor(newKonnektor.exec.name);
    for (String key in konfigSchluessel) {
      var data = await dataService.loadKonfigDefinitionDetails(
          newKonnektor.exec.name, key);

      newKonnektor.konfig.add(Konfig(
        name: key,
        value: "",
        optionen: data?.$1,
        comment: data?.$2,
        isRequired: data?.$3,
      ));
    }

    //Add new Konnektor to the list
    _konnektoren.add(newKonnektor);
    print("Added new Konnektor: ${newKonnektor.name}");

    //Set the new Konnektor as the currently editing one
    editState.tryStartEditing(_konnektoren.length - 1);

    setState(() {});
  }
}
