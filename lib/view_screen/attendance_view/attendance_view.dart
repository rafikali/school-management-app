import 'package:biometric_attendance_system/view_screen/attendance_view/attendance_view_card.dart';
import 'package:biometric_attendance_system/view_screen/attendance_view/attendancedetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({
    Key? key,
  }) : super(key: key);

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
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
          print(data);
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
                print(data);
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
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            ...listOfCourse.map((e) {
              return AttendanceViewCard(
                courseName: e['course_name'] ?? '',
                courseDay: e['course_day'] ?? '',
                courseId: e['id'] ?? '',
                courseStartTime: e['course_start_time'] ?? '',
                courseEndTime: e['course_end_time'] ?? '',
                courseTerm: e['course_term'],
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AttendeceOfCource(e['course_name'],
                          e['id'].toString(), e['course_term'])));
                  // directly showing animated card on onPressed()
                }, 
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> openHiveDB() async {
    await Hive.openBox('loginCredentials');
  }
}
