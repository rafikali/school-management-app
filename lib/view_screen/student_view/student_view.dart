import 'package:biometric_attendance_system/form_screen/form_screen.dart';
import 'package:biometric_attendance_system/view_screen/teacher_view/teacher_view_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class StudentView extends StatefulWidget {
  StudentView({
    Key? key,
  }) : super(key: key);

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  final List<Map<String, dynamic>> listOfStudents = [];

  @override
  void initState() {
    super.initState();

    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    _users.where('role', isEqualTo: 'student').get().then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        setState(() {
          listOfStudents.add(data);
        });
        print(data['full_name']);
      });
    }).whenComplete(() => EasyLoading.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        ...listOfStudents
            .map(
              (e) => TeacherViewCard(
                teacherName: '${e['id'].toString()} - ' + e['full_name'],
                userName: e['username'],
                onPressedDelete: () {
                  // Navigator.of(context).pushNamed(routeName)
                  _showDeleteDialog(
                    title: 'Do you Really want to delete?',
                    message: 'You can\'t able to recover it back',
                    context: context,
                    doc_id: e['id'].toString(),
                  );
                },
                onPressedUpdate: () => Navigator.of(context)
                    .pushNamed(FormScreen.routeName, arguments: {
                  "type": "Student",
                  "ID": e['id'],
                }),
              ),
            )
            .toList(),
      ],
    );
  }

  void _showDeleteDialog({
    required String title,
    required String message,
    required BuildContext context,
    required String doc_id,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteRecordFromFirebase(doc_id);
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _deleteRecordFromFirebase(String doc_id) {
    _users.doc('$doc_id').delete().whenComplete(() {
      EasyLoading.showSuccess('Student Removed');

      setState(() {
        listOfStudents.removeWhere((e) {
          return e['id'].toString() == '$doc_id';
        });
      });
    });
  }
}
