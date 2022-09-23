import 'package:biometric_attendance_system/form_screen/form_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'teacher_view_card.dart';

class TeacherView extends StatefulWidget {
  TeacherView({
    Key? key,
  }) : super(key: key);

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  final List<Map<String, dynamic>> listOfTeachers = [];

  @override
  void initState() {
    super.initState();

    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    _users.where('role', isEqualTo: 'teacher').get().then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        setState(() {
          listOfTeachers.add(data);
        });
        // print(data['teacher_name']);
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
        ...listOfTeachers
            .map(
              (e) => TeacherViewCard(
                teacherName: '${e['id'].toString()} - ' + e['name'],
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
                onPressedUpdate: () => Navigator.of(context).pushNamed(
                    FormScreen.routeName,
                    arguments: {"type": "Teacher", "ID": e['id']}),
              ),
            )
            .toList(),
      ],
    );
  }

  void _showDeleteDialog(
      {required String title,
      required String message,
      required BuildContext context,
      required String doc_id}) {
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
      EasyLoading.showSuccess('Teacher Removed');

      setState(() {
        listOfTeachers.removeWhere((e) {
          return e['id'].toString() == '$doc_id';
        });
      });
    });
  }
}
