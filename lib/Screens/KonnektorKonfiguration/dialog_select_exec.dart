import 'package:besodatahub/Models/data_service.dart';
import 'package:besodatahub/Models/exec.dart';
import 'package:besodatahub/Models/konnektor.dart';
import 'package:besodatahub/Utils/validation.dart';
import 'package:besodatahub/Widgets/Prebuilds/dropdown.dart';
import 'package:besodatahub/Widgets/Prebuilds/iconbutton.dart';
import 'package:besodatahub/Widgets/Prebuilds/textfield.dart';
import 'package:besodatahub/Widgets/beso_prebuilds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SelectExecDialog extends StatefulWidget {
  const SelectExecDialog({
    super.key,
  });

  @override
  State<SelectExecDialog> createState() => _SelectExecDialogState();
}

class _SelectExecDialogState extends State<SelectExecDialog> {
  final TextEditingController ctrlName = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int selectedIndex = -1;
  List<String> items = [];
  List<ExecDefinition> execs = [];
  late final DataService dataService;
  bool isLoading = true;

  @override
  void initState() {
    //Get DataService
    dataService = context.read<DataService>();
    //Prepare Items
    loadExecs();
    super.initState();
  }

  void loadExecs() async {
    execs = await dataService.loadExecsFromKonfigJson();
    items = execs.map((e) => e.name).toList();
    items.insert(0, "");
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Theme
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : BesoCard(
              width: 25.w,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Konnektornamen und Exec auswählen",
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        width: 20.w,
                        controller: ctrlName,
                        label: "Konnektor Name",
                        validator: (p0) => ValidationUtils.validateTextInput(p0,
                            minLength: 5, fieldName: "Konnektor Name"),
                      ),
                      const SizedBox(height: 10),
                      MyDropdown<String>(
                        label: "Exe auswählen",
                        width: 20.w,
                        items: items,
                        validator: ValidationUtils.required(),
                        value: selectedIndex == -1 ? "" : items[selectedIndex],
                        onChanged: (value) => setState(() {
                          selectedIndex = items.indexOf(value!);
                        }),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyIconButton(
                            icondata: Icons.check_outlined,
                            iconColor: Colors.green,
                            iconSize: 5.sp,
                            onPressed: () => createNewKonnektor(),
                          ),
                          const SizedBox(width: 10),
                          MyIconButton(
                            icondata: Icons.close_outlined,
                            iconSize: 5.sp,
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void createNewKonnektor() {
    // Validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
        context,
        Konnektor(
          name: ctrlName.text,
          exec: execs[
              selectedIndex - 1], // -1 because of the empty string at index 0
          konfig: [],
        ));
  }
}
