import 'package:besodatahub/Models/data_service.dart';
import 'package:besodatahub/Models/konfig.dart';
import 'package:besodatahub/Models/konnektor.dart';
import 'package:besodatahub/Provider/edit_state.dart';
import 'package:besodatahub/Widgets/Prebuilds/dropdown.dart';
import 'package:besodatahub/Widgets/Prebuilds/expansiontile.dart';
import 'package:besodatahub/Widgets/Prebuilds/iconbutton.dart';
import 'package:besodatahub/Widgets/Prebuilds/textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class KonnektorKonfigurationLine extends StatefulWidget {
  final int index;
  final Konnektor konnektor;
  final bool isEditing;
  final VoidCallback onEditStart;
  final Function(Konnektor konfig) onSave;
  const KonnektorKonfigurationLine(
      {super.key,
      required this.konnektor,
      required this.onEditStart,
      required this.onSave,
      required this.isEditing,
      required this.index});

  @override
  State<KonnektorKonfigurationLine> createState() =>
      _KonnektorKonfigurationLineState();
}

class _KonnektorKonfigurationLineState
    extends State<KonnektorKonfigurationLine> {
  late final Konnektor _originalKonnektor;
  late Konnektor _konnektor;

  final Map<String, TextEditingController> _textControllers = {};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ExpansionTileController _ctrlExpansionTile = ExpansionTileController();

  bool _unsavedChanges = false;

  late final DataService dataService;

  @override
  void didUpdateWidget(KonnektorKonfigurationLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the editing status for this specific widget has changed
    if (!widget.isEditing && widget.isEditing != oldWidget.isEditing) {
      // Just stopped editing this line
      if (_ctrlExpansionTile.isExpanded) {
        print("didUpdateWidget: Collapsing tile for ${widget.konnektor.name}");
        _ctrlExpansionTile.collapse();
      }
    }
  }

  @override
  void initState() {
    dataService = context.read<DataService>();
    _originalKonnektor = widget.konnektor.copy();
    _konnektor = widget.konnektor;
    initTextControllers();

    super.initState();
  }

  @override
  void dispose() {
    disposeTextControllers();
    super.dispose();
  }

  void disposeTextControllers() {
    for (var ctrl in _textControllers.values) {
      ctrl.dispose();
    }
  }

  void initTextControllers() {
    if (_textControllers.isNotEmpty) {
      disposeTextControllers();
    }
    for (var konfig in _konnektor.konfig) {
      TextEditingController ctrl = TextEditingController(text: konfig.value);
      ctrl.addListener(() => setState(() {
            konfig.value = ctrl.text;
            checkUnsavedChanges();
          }));
      _textControllers[konfig.name] = ctrl;
    }
  }

  void checkUnsavedChanges() {
    final editState = context.read<EditState>();

    if (_konnektor == _originalKonnektor) {
      editState.updateDirtyStatus(false);
    } else {
      editState.updateDirtyStatus(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editState = context.watch<EditState>();
    _unsavedChanges = editState.isCurrentLineEditDirty;
    final ThemeData themeData = Theme.of(context);
    return Form(
      key: _formKey,
      child: MyExpansionTile(
        initiallyExpanded: widget.isEditing,
        controller: _ctrlExpansionTile,
        removeDefaultIcon: true,
        //Methods
        onExpansionChanged: (isExpanded) async {
          print("Detected expansion change: $isExpanded");
          if (!isExpanded && widget.isEditing) {
            print(
                "Detected collapse of Konnektor: ${widget.konnektor.name} while editing");
            // Stop editing this line
            bool cancelEdit = await editState.cancelEditing(context);

            if (!cancelEdit) {
              _ctrlExpansionTile.expand();
            }
          }
        },
        //Children
        leading: SizedBox(
          width: 5,
          child: _unsavedChanges && widget.isEditing
              ? Icon(Icons.circle, color: themeData.colorScheme.error, size: 10)
              : null,
        ),
        title: Row(
          children: [
            Text(_konnektor.name,
                style: themeData.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(width: 10),
            Text(
              " (${_konnektor.exec.name})",
            ),
            const Spacer(),
            ..._getToolButtons(),
            const SizedBox(width: 10),
          ],
        ),
        children: _konnektor.konfig.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "No Konfigs available",
                    textAlign: TextAlign.left,
                  ),
                )
              ]
            : _konnektor.konfig.map((konfig) {
                return _getKonnektorKonfigLine(konfig);
              }).toList(),
      ),
    );
  }

  List<Widget> _getToolButtons() {
    return [
      MyIconButton(
        tooltip: "Save Konnektor",
        icondata: Icons.save_outlined,
        enabled: widget.isEditing && _unsavedChanges,
        padding: 0,
        iconSize: 4.sp,
        onPressed: () => saveKonnektor(),
      ),
      const SizedBox(width: 10),
      MyIconButton(
        tooltip: "Revert Changes",
        icondata: Icons.restore_outlined,
        enabled: widget.isEditing && _unsavedChanges,
        padding: 0,
        iconSize: 4.sp,
        onPressed: () => revertChanges(),
      ),
      const SizedBox(width: 10),
      MyIconButton(
        tooltip: "Edit Konnektor",
        icondata: Icons.edit_outlined,
        enabled: !widget.isEditing,
        padding: 0,
        iconSize: 4.sp,
        onPressed: () => editKonnektor(),
      ),
      const SizedBox(width: 10),
      MyIconButton(
        tooltip: "Delete Konnektor",
        icondata: Icons.delete_outlined,
        padding: 0,
        iconSize: 4.sp,
        onPressed: () => deleteKonnektor(),
      ),
    ];
  }

  Widget _getKonnektorKonfigLine(Konfig konfig) {
    final themeData = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 10.w,
          child: Tooltip(
            message: konfig.comment ?? "",
            exitDuration: const Duration(milliseconds: 100),
            enableTapToDismiss: true,
            child: Text(
              konfig.name,
              textAlign: TextAlign.end,
              style: themeData.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: widget.isEditing
              ? konfig.optionen != null && konfig.optionen!.isNotEmpty
                  ? MyDropdown<String>(
                      outsidePadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      //Add Empty Placeholder if not required
                      items: konfig.isRequired!
                          ? konfig.optionen!
                          : ["", ...konfig.optionen!],
                      value: konfig.value,
                      onChanged: (value) => setState(() {
                        // If konfig is required, set first option as default
                        // If konfig is not required, set empty string as default
                        konfig.isRequired!
                            ? value ??= konfig.optionen!.first
                            : value ??= "";
                        value ??= "";

                        _textControllers[konfig.name]!.text = value!;
                        konfig.value = value!;
                        checkUnsavedChanges();
                      }),
                    )
                  : MyTextField(
                      controller: _textControllers[konfig.name],
                      outsidePadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    )
              : MyTextField(
                  initialValue: konfig.value,
                  readOnly: true,
                  outsidePadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
        ),
      ],
    );
  }

  void editKonnektor() async {
    final editState = context.read<EditState>();
    if (editState.tryStartEditing(widget.index)) {
      _ctrlExpansionTile.expand();
      print("Edit allowed for index ${widget.index}");
      // Load Edit Konfigs
      final String execName = _konnektor.exec.name;
      // All Konfigs for Konnektor -> From Konfig JSON
      print("1");
      List<String> availableKonfigs =
          await dataService.loadKonfigSchluesselForKonnektor(execName);
      // Konfigs currently used by Konnektor -> From SQL
      print("2");
      List<String> appliedKonfigs =
          _konnektor.konfig.map((e) => e.name).toList();
      // Konfigs to be added for editing
      List<String> konfigsToAdd = availableKonfigs
          .where((konfig) => !appliedKonfigs.contains(konfig))
          .toList();
      print("3");
      // Update currently Used Konfigs -> Add Comment, isRequired, Options
      for (Konfig konfig in _konnektor.konfig) {
        var details = await dataService.loadKonfigDefinitionDetails(
            execName, konfig.name);
        if (details != null) {
          konfig.optionen = details.$1;
          konfig.comment = details.$2;
          konfig.isRequired = details.$3;
        }
      }
      print(4);

      // Add Konfigs to be added for editing
      for (String konfigName in konfigsToAdd) {
        var details =
            await dataService.loadKonfigDefinitionDetails(execName, konfigName);
        if (details != null) {
          Konfig newKonfig = Konfig(
              name: konfigName,
              value: "",
              comment: details.$2,
              optionen: details.$1,
              isRequired: details.$3);
          _konnektor.konfig.add(newKonfig);
          _textControllers[konfigName] = TextEditingController(text: "");
        }
      }
      print(5);
      setState(() {});
    } else {
      print("Edit blocked for index ${widget.index}");
    }
  }

  void deleteKonnektor() {}

  void saveKonnektor() {
    widget.onSave.call(_konnektor);
    context.read<EditState>().forceStopEditing();
    setState(() {
      initTextControllers();
    });
  }

  void revertChanges() {
    if (_unsavedChanges) {
      setState(() {
        _konnektor = _originalKonnektor.copy();
        initTextControllers();
        context.read<EditState>().updateDirtyStatus(false);
      });
    }
  }
}
