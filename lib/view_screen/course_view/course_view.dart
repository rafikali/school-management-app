
import 'package:biometric_attendance_system/form_screen/form_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'course_view_card.dart';

class CourseView extends StatefulWidget {
  final String role;

  CourseView({Key? key, required this.role}) : super(key: key);

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  final CollectionReference _course =
      FirebaseFirestore.instance.collection('courses');

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Map<String, dynamic> studentInfo = {};

  List<Map<String, dynamic>> listOfCourse = [];
  List<String> electedCourses = [];

  @override
  void initState() {
    openHiveDB();
    super.initState();

    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    if (Hive.box('loginCredentials').get('role').toString() == 'admin') {
      _course.get().then((value) {
        value.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          setState(() {
            listOfCourse.add(data);
          });
          print(data['course_name']);
        });
      }).whenComplete(() => EasyLoading.dismiss());
    } else {
      getElectedCourses();
    }
  }

  void getElectedCourses() {
    int? userId =
        int.tryParse(Hive.box('loginCredentials').get('id').toString());
    print(userId);
    if (Hive.box('loginCredentials').isOpen) {
      _users.where('id', isEqualTo: userId).limit(1).get().then((value) {
        print(value.size);
        value.docs.forEach((doc) {
          print(doc.exists);
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          setState(() {
            if (data['role'] == 'admin') {
              setState(() {
                listOfCourse.add(data);
              });
            }
            for (final element in data['courses']) {
              electedCourses.add(element);
            }
          });
          print(data['full_name']);
        });
      }).whenComplete(() => {
            _course
                .where('course_name', whereIn: electedCourses)
                .get()
                .then((value) {
              print("Doc Size: " + value.size.toString());
              value.docs.forEach((doc) {
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                setState(() {
                  listOfCourse.add(data);
                });
                print(data['course_name']);
              });
            }).whenComplete(() => EasyLoading.dismiss()),
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(listOfCourse);
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            ...listOfCourse.map((e) {
              return CourseViewCard(
                Id: e['id'] ?? '',
                courseName: e['course_name'] ?? '',
                courseDay: e['course_day'] ?? '',
                courseStartTime: e['course_start_time'] ?? '',
                courseEndTime: e['course_end_time'] ?? '',
                role: widget.role,
                onPressedDelete: () {
                  _showDeleteDialog(
                    title: 'Do you Really want to delete?',
                    message: 'You can\'t able to recover it back',
                    context: context,
                    doc_id: e['id'].toString(),
                  );
                },
                onPressedUpdate: () => Navigator.of(context).pushNamed(
                    FormScreen.routeName,
                    arguments: {"type": "Course", "ID": e['id']}),
              );
            }).toList(),
          ],
        ),
      ),
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
    
    _course.doc('$doc_id').delete().whenComplete(() {
      EasyLoading.showSuccess('Course Deleted');
      
      setState(() {
        listOfCourse.removeWhere((e) {
          return e['id'].toString() == '$doc_id';
        });
      });
    });
  }

  Future<void> openHiveDB() async {
    await Hive.openBox('loginCredentials');
  }
}
