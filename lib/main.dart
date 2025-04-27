import 'package:besodatahub/Models/data_service.dart';
import 'package:besodatahub/Screens/Jobfolge/jobfolgen_main.dart';
import 'package:besodatahub/Widgets/beso_prebuilds.dart';
import 'package:besodatahub/Provider/edit_state.dart';
import 'package:besodatahub/Theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'Screens/KonnektorKonfiguration/konnektor_konfiguration_main.dart';

void main() {
  runApp(MultiProvider(providers: [
    //DataService Provider -> One Line so not extra class
    Provider<DataService>(create: (_) => DataService()),
  ], child: const BesoDataHub()));
}

class BesoDataHub extends StatelessWidget {
  const BesoDataHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter App',
        theme: themeData,
        home: const HomeScreen(),
      );
    });
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const BesoAppBar(title: 'Beso Data Hub'),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getMenuCard('Jobfolgen', const JobFolgenMainScreen(), context),
                // getMenuCard(
                //     'Job\nKonfiguration', const JobKonfiguration(), context),
                getMenuCard(
                    'Konnektor Konfiguration',
                    ChangeNotifierProvider(
                      create: (context) => EditState(),
                      child: const KonnektorKonfiguration(),
                    ),
                    context),
              ],
            ),
          ],
        ));
  }

  Widget getMenuCard(String title, Widget targetPage, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      ),
      child: BesoCard(
        padding: const EdgeInsets.all(32),
        height: 30.h,
        width: 30.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.arrow_forward,
              color: themeData.colorScheme.primary,
              size: 10.sp,
            ),
          ],
        ),
      ),
    );
  }
}
