import 'package:biometric_attendance_system/form_screen/add_student_form.dart';
import 'package:biometric_attendance_system/form_screen/add_teacher_form.dart';
import 'package:flutter/material.dart';

import 'add_course_form.dart';

class FormScreen extends StatefulWidget {
  static String routeName = "FormScreen";

  const FormScreen({Key? key}) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  @override
  Widget build(BuildContext context) {
    final formType = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.blue,
        centerTitle: true,
        // elevation: 0,
        title: Text(formType['type'] + " Form"),
      ),
      body: SafeArea(
        child: formType['type'] == "Student"
            ? AddStudentForm(studentId: formType['ID'].toString(),)
            : formType['type'] == "Teacher"
                ? AddTeacherForm(teacherId: formType['ID'].toString(),)
                : formType['type'] == "Course"
                    ? AddCourseForm(courseId: formType['ID'].toString(),)
                        : const Center(
                            child: Text(
                                "you are unethically trying to access our system"),
                          ),
      ),
    );
  }
}
