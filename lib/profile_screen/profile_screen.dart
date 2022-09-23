import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'admin_profile.dart';
import 'student_profile.dart';
import 'teacher_profile.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "ProfileScreen";

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final formType = ModalRoute.of(context)!.settings.arguments as String;

    print("Profile Screen: "+formType);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.blue,
        centerTitle: true,
        // elevation: 0,
        title: Text(formType + " Profile"),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              formType == "Admin"
                  ? const AdminProfile(
                      iconData: FontAwesomeIcons.userCog,
                    )
                  : formType == "Teacher"
                      ? const TeacherProfile(
                          iconData: FontAwesomeIcons.chalkboardTeacher,
                        )
                      : formType == "Student"
                          ? const StudentProfile(
                              iconData: FontAwesomeIcons.userGraduate,
                            )
                          : const Center(
                              child: Text(
                                  "you are unethically trying to access our system"),
                            ),
            ],
          ),
        ),
      ),
    );
  }

}
