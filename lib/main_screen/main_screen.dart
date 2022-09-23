import 'package:biometric_attendance_system/authentication_screen/authentication_screen.dart';
import 'package:biometric_attendance_system/main_screen/role_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainScreen extends StatefulWidget {
  static String routeName = "MainScreen";

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.blue,
        centerTitle: true,
        // elevation: 0,
        title: const Text(
          'Biometric Attendance System',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Icon(
                FontAwesomeIcons.fingerprint,
                size: 100,
              ),
            ),
            Container(
              height: 2,
              margin: const EdgeInsets.only(left: 15, right: 15),
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RoleCard(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthenticationScreen(
                            iconData: FontAwesomeIcons.userCog, role: "Admin"),
                      ),
                    );
                  },
                  iconData: FontAwesomeIcons.userCog,
                  role: "Admin",
                ),
                RoleCard(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthenticationScreen(
                            iconData: FontAwesomeIcons.chalkboardTeacher,
                            role: "Teacher"),
                      ),
                    );
                  },
                  iconData: FontAwesomeIcons.chalkboardTeacher,
                  role: "Teacher",
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RoleCard(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthenticationScreen(
                            iconData: FontAwesomeIcons.userGraduate,
                            role: "Student"),
                      ),
                    );
                  },
                  iconData: FontAwesomeIcons.userGraduate,
                  role: "Student",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
