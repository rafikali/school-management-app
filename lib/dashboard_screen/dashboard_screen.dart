import 'package:biometric_attendance_system/dashboard_screen/dashboard_cards.dart';
import 'package:biometric_attendance_system/form_screen/form_screen.dart';
import 'package:biometric_attendance_system/profile_screen/profile_screen.dart';
import 'package:biometric_attendance_system/view_screen/view_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "DashboardScreen";

  final IconData iconData;
  final String role;

  const DashboardScreen({Key? key, required this.iconData, required this.role})
      : super(key: key);

  final String _ID='';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.blue,
        centerTitle: true,
        // elevation: 0,
        title: Text(widget.role + " Dashboard"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: widget.role == "Admin"
              ? _showAdminCards()
              : widget.role == "Teacher"
                  ? _showTeacherCards()
                  : widget.role == "Student"
                      ? _showStudentCards()
                      : const Text(
                          "you are unethically trying to access our system"),
        ),
      ),
    );
  }

  // Return Admin Cards~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _showAdminCards() {
    return Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'Add Student',
              iconData: FontAwesomeIcons.userGraduate,
              onPressed: () => Navigator.of(context).pushNamed(
                  FormScreen.routeName,
                  arguments: {"type": "Student", "ID": widget._ID}),
            ),
            DashboardCard(
              text: 'Add Teacher',
              iconData: FontAwesomeIcons.chalkboardTeacher,
              onPressed: () => Navigator.of(context).pushNamed(
                  FormScreen.routeName,
                  arguments: {"type": "Teacher", "ID": widget._ID}),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'Add Course',
              iconData: FontAwesomeIcons.book,
              onPressed: () => Navigator.of(context).pushNamed(
                  FormScreen.routeName,
                  arguments: {"type": "Course", "ID": widget._ID}),
            ),
            DashboardCard(
              text: 'View Attendance',
              iconData: FontAwesomeIcons.clipboardList,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Attendance"),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'View Courses',
              iconData: FontAwesomeIcons.book,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Admin Course"),
            ),
            DashboardCard(
              text: 'View Students',
              iconData: FontAwesomeIcons.userGraduate,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Student"),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'View Teachers',
              iconData: FontAwesomeIcons.chalkboardTeacher,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Teacher"),
            ),
            DashboardCard(
              text: 'View Profile',
              iconData: FontAwesomeIcons.userEdit,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ProfileScreen.routeName, arguments: "Admin"),
            ),
          ],
        )
      ],
    );
  }

// Return Teacher Cards~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _showTeacherCards() {
    return Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'View Attendance',
              iconData: FontAwesomeIcons.clipboardList,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Attendance"),
            ),
            DashboardCard(
              text: 'View Course',
              iconData: FontAwesomeIcons.book,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Course"),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'View Profile',
              iconData: FontAwesomeIcons.userEdit,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ProfileScreen.routeName, arguments: "Teacher"),
            ),
          ],
        )
      ],
    );
  }

// Return Student Cards~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _showStudentCards() {
    return Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'View Attendance',
              iconData: FontAwesomeIcons.userGraduate,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Attendance"),
            ),
            DashboardCard(
              text: 'View Course',
              iconData: FontAwesomeIcons.book,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ViewScreen.routeName, arguments: "Course"),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DashboardCard(
              text: 'Profile',
              iconData: FontAwesomeIcons.userEdit,
              onPressed: () => Navigator.of(context)
                  .pushNamed(ProfileScreen.routeName, arguments: "Student"),
            ),
          ],
        )
      ],
    );
  }
}
