import 'package:biometric_attendance_system/view_screen/attendance_view/attendance_view.dart';
import 'package:biometric_attendance_system/view_screen/course_view/course_view.dart';
import 'package:biometric_attendance_system/view_screen/student_view/student_view.dart';
import 'package:biometric_attendance_system/view_screen/teacher_view/teacher_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewScreen extends StatelessWidget {
  static String routeName = "ViewScreen";

  const ViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewType = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.blue,
        centerTitle: true,
        // elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(viewType + " View"),
            const SizedBox(
              width: 20,
            ),
            viewType == "Attendance"
                ? const Icon(
                    FontAwesomeIcons.clipboardList,
                    size: 30,
                  )
                : const Icon(
                    FontAwesomeIcons.book,
                    size: 30,
                  ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: viewType == "Attendance"
                ? const AttendanceView()
                : viewType == "Course"
                    ? CourseView(role: viewType,)
            : viewType == "Course" || viewType == "Admin Course"
                ? CourseView(role: viewType,)
                    : viewType == "Teacher"
                        ? TeacherView()
                        : viewType == "Student"
                            ? StudentView()
                            : const Center(
                                child: Text(
                                    "you are unethically trying to access our system"),
                              ),
          ),
        ),
      ),
    );
  }
}
