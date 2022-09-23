import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// Student view attendance file ####################################
class AttendeceOfCource extends StatefulWidget {
  AttendeceOfCource(this.coursename, this.courseid, this.courseterm);
  String coursename, courseid, courseterm;
  @override
  State<AttendeceOfCource> createState() => _AttendeceOfCourceState();
}

class _AttendeceOfCourceState extends State<AttendeceOfCource> {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  List<Map<String, dynamic>> listOfCourse = [];
  List<String> electedCourses = [];

  void getElectedUsers() {
    _users.where('course_name', whereIn: electedCourses).get().then((value) {
      print("Doc Size: " + value.size.toString());
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        setState(() {
          listOfCourse.add(data);
        });
        print(data['course_name']);
      });
    }).whenComplete(() => EasyLoading.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(widget.courseid + ' - ' + widget.coursename),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) => Card(
                child: DataTable(
                  showBottomBorder: true,
                  sortColumnIndex: 0,
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) =>
                        Theme.of(context).primaryColor,
                  ),
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Term',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Student Id',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Student Name',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total Presents',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total Absences',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                  rows: [],
                ),
              ),
            ),
          ),

          // Row(
          //   children: [
          //     Text("Term"),
          //     Text("Student Id"),
          //     Text("Student Name"),
          //     Text("Total Presents"),
          //     Text("Total Absences"),
          //   ],
          // )
        ],
      ),
    );
  }
}
