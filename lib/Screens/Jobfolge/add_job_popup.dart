import 'package:besodatahub/Models/data_service.dart';
import 'package:besodatahub/Models/konnektor.dart';
import 'package:besodatahub/Utils/validation.dart';
import 'package:besodatahub/Widgets/Prebuilds/dropdown.dart';
import 'package:besodatahub/Widgets/Prebuilds/iconbutton.dart';
import 'package:besodatahub/Widgets/Prebuilds/textfield.dart';
import 'package:besodatahub/Widgets/beso_prebuilds.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AddJobPopup extends StatefulWidget {
  const AddJobPopup({super.key});

  @override
  State<AddJobPopup> createState() => _AddJobPopupState();
}

class _AddJobPopupState extends State<AddJobPopup> {
  final DataService _dataService = DataService();
  final TextEditingController _jobNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add form key for validation

  List<String> _konnektorNameList = [];
  String? _selectedKonnektorName;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKonnektors();
  }

  Future<void> _loadKonnektors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final konnektors = await _dataService.loadKonnektorOverview();
      setState(() {
        _konnektorNameList = konnektors.map((k) => k.name).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load Konnektors: $e";
        _isLoading = false;
      });
      print("Error loading Konnektors: $e");
    }
  }

  @override
  void dispose() {
    _jobNameController.dispose();
    super.dispose();
  }

  void _onApply() {
    if (_formKey.currentState!.validate()) {
      // Validate the form
      if (_selectedKonnektorName != null) {
        Navigator.pop(context, {
          'Name': _jobNameController.text.trim(),
          'Konnektor': _selectedKonnektorName,
        });
      } else {
        // Should ideally not happen if validation passes, but as a safeguard:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a Konnektor.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AlertDialog(
        backgroundColor: Colors.transparent,
        content: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : BesoCard(
                width: 25.w,
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Wichtig für die minimale Höhe
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // Kinder strecken
                    children: [
                      Row(
                        children: [
                          Text("Add new Job",
                              style: theme.textTheme.headlineMedium),
                          const Spacer(),
                          MyIconButton(
                              icondata: Icons.close,
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                      MyDropdown(
                        label: "Konnektor auswählen",
                        sizeBehavior: FormFieldSizeBehavior.intrinsicSize,
                        validator: ValidationUtils.required(),
                        items: _konnektorNameList,
                        value: _selectedKonnektorName,
                        onChanged: (value) {
                          setState(() {
                            _selectedKonnektorName = value;
                          });
                        },
                      ),
                      MyTextField(
                          label: "Jobname",
                          sizeBehavior: FormFieldSizeBehavior.intrinsicSize,
                          controller: _jobNameController,
                          validator: (p0) => ValidationUtils.validateTextInput(
                              p0,
                              minLength: 4,
                              fieldName: "Jobname")),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyIconButton(
                            icondata: Icons.check,
                            onPressed: _onApply,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
  }
}
