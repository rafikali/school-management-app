import 'dart:ffi';

import 'package:biometric_attendance_system/view_screen/attendance_view/attendance_details_1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceDetails extends StatefulWidget {
  final String courseName, courseId, courseTime, courseTerm;
  final int attend = 0;

  AttendanceDetails({
    Key? key,
    required this.courseName,
    required this.courseId,
    required this.courseTime,
    required this.courseTerm,
  }) : super(key: key);

  @override
  State<AttendanceDetails> createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  // -------------------SharedPreferences------------------------
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? _counterP = '0';
  String? _counterA = '0';
  Future readPA() async {
    final SharedPreferences prefs = await _prefs;
    _counterP =
        prefs.getString('counterP_${hiveUserId}') ?? totalPresents.toString();
    _counterA =
        prefs.getString('counterA_${hiveUserId}') ?? totalAbsents.toString();
    print(_counterP);
    print(_counterA);
  }

  // Future WritePA() async {
  //   final SharedPreferences prefs = await _prefs;

  //   setState(() {
  //     p.text == ''
  //         ? prefs.setString('counterP_${hiveUserId}', totalPresents.toString())
  //         : prefs.setString('counterP_${hiveUserId}', p.text.toString());
  //     a.text == ''
  //         ? prefs.setString('counterA_${hiveUserId}', totalAbsents.toString())
  //         : prefs.setString('counterA_${hiveUserId}', a.text.toString());

  //     // print(p.text.toString());5
  //   });
  // }

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  double textSize = 12;

  // int? userId =
  // int.tryParse(Hive.box('loginCredentials').get('id').toString());

  final DatabaseReference attendanceNodeRef =
      FirebaseDatabase.instance.ref("attendance");

  final int? hiveUserId =
      int.tryParse(Hive.box('loginCredentials').get('id').toString());

  final bool isStudent =
      Hive.box('loginCredentials').get('role').toString() == 'student';

  List<int> studentIdsFromRealTimeDB = [];

  late List<Map<String, dynamic>> listOfStudents = [];

  var tempList = [
    {"noArgs": "loading Data..."},
  ];

  late List<Map<String, dynamic>> listOfAttendance = [];

  bool attendanceCorrector = true;
  int totalPresents = 0;
  var totalAbsents = 0;
  var last = 0.0;

  DateTime previousDate = DateTime.now();

  Future<void> getDataFromFirebase() async {
    bool isTwoTimes = false;
    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    await attendanceNodeRef.once().then((var snapshots) {
      //here i iterate and create the list of objects
      Map<dynamic, dynamic>? attendanceRecords =
          snapshots.snapshot.value as Map?;
      attendanceRecords!.forEach((key, value) {
        setState(() {
          studentIdsFromRealTimeDB.add(int.parse(key));
        });
        //printing status
        print("Getting keys (ids) from RT: " + key);
      });
    });

    await _users
        .where('role', isEqualTo: 'student')
        .where('courses', arrayContains: widget.courseName)
        .where('id', whereIn: studentIdsFromRealTimeDB)
        .get()
        .then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> dataOfStudents =
            doc.data()! as Map<String, dynamic>;
        setState(() {
          listOfStudents.add(dataOfStudents);
          // print(listOfStudents);
        });
        print("(AttendanceDetails) Loaded Data of : " +
            dataOfStudents['full_name']);
      });
    });

    listOfStudents.forEach((element) async {
      //166931
      final DatabaseReference studentNodeRef =
          FirebaseDatabase.instance.ref("attendance/${element['id']}");
      // Get the data once
      await studentNodeRef
          .orderByValue()
          .limitToLast(1)
          .once()
          .then((var snapshots) {
        //here i iterate and create the list of objects
        Map<dynamic, dynamic>? attendanceRecords =
            snapshots.snapshot.value as Map?;
        attendanceRecords!.forEach((key, value) {
          String record = value;
          int datetimeInEpoch = int.tryParse(record.substring(11, 21)) as int;

          // print("datetimeInEpoch: " + datetimeInEpoch.toString());
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(datetimeInEpoch * 1000)
                  .subtract(Duration(hours: 1));

          String formatTime = DateFormat('hh:mm a').format(dateTime);

          String formatDate = DateFormat('dd/MM/yyyy').format(dateTime);

          print("TIME: " + value.substring(29, 36));

          setState(() {
            listOfAttendance.add({
              'CheckIn':
                  '${value.substring(29, 36) == "checkin" ? '$formatTime' : '-'}',
              'CheckOut':
                  '${value.substring(29, 36) == "checkout" ? '$formatTime' : '-'}',
              'Date': '$formatDate',
            });
            print("Attendence corrector : " + '$attendanceCorrector');

            attendanceCorrector
                ? listOfAttendance.add({
                    'CheckIn': '$formatTime',
                    'Date': '$formatDate',
                  }) // || list.length.add(listOfAttendance.length)
                : listOfAttendance.add({
                    'CheckOut': '$formatTime',
                    'Date': '$formatDate',
                  });
            // print(listOfAttendance.length.toString()+'!!!!!!!!!!!!!!!!!!!!!!!!');
            // list.add(listOfAttendance.length);
            // for (int i = 1; i >= list.length; i++) {
            //   last = list[i];
            // }
            ;
            // print(last);
            // Edit the timing conditions from there~~~~~~~~~~~~~~~~
            if (isAfter30Mints(
                currentTime: dateTime, previousTime: previousDate)) {
              setState(() {
                totalPresents += 1;
                // print(totalPresents.toString() + 'P');
              });
            } else if (!isAfter30Mints(
                currentTime: dateTime, previousTime: previousDate)) {
              setState(() {
                if (isTwoTimes == true) {
                  totalAbsents = last / 2 as int;
                  // print(totalAbsents.toString() + 'A');
                }
                isTwoTimes = !isTwoTimes;
              });
            }
          });

          //printing timeStamp
          print(formatTime);
          //printing status
          print(value.substring(29, 36));
          previousDate = dateTime;
          attendanceCorrector = !attendanceCorrector;
        });
      }).whenComplete(() => EasyLoading.dismiss());
    });
  }

  Future<void> getStudentRecord() async {
    bool isTwoTimes = false;

    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    print(hiveUserId);

    if (Hive.box('loginCredentials').isOpen) {
      //166931
      final DatabaseReference studentNodeRef =
          FirebaseDatabase.instance.ref("attendance/${hiveUserId}");

      // Get the data once
      studentNodeRef.once().then((var snapshots) {
        //here i iterate and create the list of objects
        Map<dynamic, dynamic>? attendanceRecords =
            snapshots.snapshot.value as Map?;

        attendanceRecords!.forEach((key, value) {
          String record = value;

          int datetimeInEpoch = int.tryParse(record.substring(11, 21)) as int;
          print("datetimeInEpoch: " + datetimeInEpoch.toString());
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(datetimeInEpoch * 1000)
                  .subtract(Duration(hours: 1));

          String formatTime = DateFormat('hh:mm a').format(dateTime);

          String formatDate = DateFormat('dd/MM/yyyy').format(dateTime);

          setState(() {
            attendanceCorrector
                ? listOfAttendance.add({
                    'CheckIn': '$formatTime',
                    'Date': '$formatDate',
                  })
                : listOfAttendance.add({
                    'CheckOut': '$formatTime',
                    'Date': '$formatDate',
                  });

            // Edit the timing conditions from there~~~~~~~~~~~~~~~~
            if (isAfter30Mints(
                currentTime: dateTime, previousTime: previousDate)) {
              setState(() {
                totalPresents += 1;
              });
            } else if (!isAfter30Mints(
                currentTime: dateTime, previousTime: previousDate)) {
              setState(() {
                if (isTwoTimes == true) {
                  totalAbsents += 1;
                }
                isTwoTimes = !isTwoTimes;
              });
            }
          });

          //printing timeStamp
          // print(formatTime);
          //printing status for useless
          // print(value.substring(29, 36));
          previousDate = dateTime;
          attendanceCorrector = !attendanceCorrector;
        });
      }).whenComplete(() => EasyLoading.dismiss());
    }
  }

  // bool isDayChanged({required DateTime dayBefore, required DateTime dayAfter}) {
  //   if (dayBefore.day < dayAfter.day)
  //     return true;
  //   else
  //     return false;
  // }

  bool isAfter30Mints(
      {required DateTime previousTime, required DateTime currentTime}) {
    if (currentTime.minute - previousTime.minute > 3)
      return true;
    else
      return false;
  }

  final List<Map<String, dynamic>> studentsDataList = [];
  var studentsData;
  @override
  void initState() {
    super.initState();
    readPA();
    if (isStudent) {
      getStudentRecord();
    } else {
      getDataFromFirebase();
    }
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
          studentsDataList.add(data);
        });
        // print(data['full_name']);
      });
    }).whenComplete(() {
      EasyLoading.dismiss();
      for (int i = 0; i < studentsDataList.length; i++) {
        if (studentsDataList[i]['id'].toString() == hiveUserId.toString()) {
          studentsData = studentsDataList[i];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 120,
        backgroundColor: Colors.blue,
        title: Column(
          children: [
            const Text("Attendance Details"),
            Container(
              color: Colors.black45,
              height: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
            ),
            Text(widget.courseId + ' - ' + widget.courseName),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "close ",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.times,
                        color: Colors.red,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                isStudent
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'SSID : ' + studentsData['id'].toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Student name : ' +
                                      studentsData['full_name'].toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Term : ' + widget.courseTerm,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Time : ' + widget.courseTime,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(),

                const SizedBox(
                  height: 20,
                ),
                isStudent
                    ? DataTable(
                        showBottomBorder: true,
                        sortColumnIndex: 0,
                        headingRowColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) =>
                              Theme.of(context).primaryColor,
                        ),
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Date',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: textSize,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Check-In',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: textSize,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Check-Out',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                fontSize: textSize,
                              ),
                            ),
                          ),
                        ],

                        //Row Data~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        rows: isStudent
                            ? listOfAttendance // Loops through dataColumnText, each iteration assigning the value to element
                                .map(
                                  (element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(
                                        element["Date"] ?? '',
                                        style: TextStyle(
                                          fontSize: textSize,
                                        ),
                                      )),
                                      //Extracting from Map element the value
                                      DataCell(Text(
                                        (element)["CheckIn"] ?? '',
                                        style: TextStyle(
                                          fontSize: textSize,
                                        ),
                                      )),
                                      DataCell(Text(
                                        (element)["CheckOut"] ?? '',
                                        style: TextStyle(
                                          fontSize: textSize,
                                        ),
                                      )),
                                    ],
                                  ),
                                )
                                .toList()
                            : tempList
                                .map(
                                  (element) => DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(
                                        element["noArgs"] ?? '',
                                        style: TextStyle(
                                          fontSize: textSize,
                                        ),
                                      )),
                                      //Extracting from Map element the value
                                      DataCell(Text(
                                        element["noArgs"] ?? '',
                                        style: TextStyle(
                                          fontSize: textSize,
                                        ),
                                      )),
                                      DataCell(Text(
                                        element["noArgs"] ?? '',
                                        style: TextStyle(
                                          fontSize: textSize,
                                        ),
                                      )),
                                    ],
                                  ),
                                )
                                .toList(),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                                  fontSize: textSize,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'SSID',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: textSize,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: textSize,
                                ),
                              ),
                            ),
                            // DataColumn(
                            //   label: Text(
                            //     'Total\nPresent',
                            //     style: TextStyle(
                            //       fontStyle: FontStyle.italic,
                            //       color: Colors.white,
                            //       fontSize: textSize,
                            //     ),
                            //   ),
                            // ),
                            // DataColumn(
                            //   label: Text(
                            //     'Total\nAbseces',
                            //     style: TextStyle(
                            //       fontStyle: FontStyle.italic,
                            //       color: Colors.white,
                            //       fontSize: textSize,
                            //     ),
                            //   ),
                            // ),
                            // DataColumn(
                            //   label: Text(
                            //     'Check-Out',
                            //     style: TextStyle(
                            //       fontStyle: FontStyle.italic,
                            //       color: Colors.white,
                            //       fontSize: textSize,
                            //     ),
                            //   ),
                            // ),
                          ],

                          //Row Data~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                          rows: listOfStudents.length >= 0 &&
                                  listOfStudents.isNotEmpty &&
                                  listOfAttendance.length >= 0 &&
                                  listOfAttendance.isNotEmpty
                              ? listOfStudents // Loops through dataColumnText, each iteration assigning the value to element
                                  .map(
                                    (element) => DataRow(
                                      onLongPress: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AttendanceDetails1(
                                                      courseName:
                                                          widget.courseName,
                                                      courseId: widget.courseId,
                                                      courseTime:
                                                          widget.courseTime,
                                                      id: int.parse(
                                                          element['id']
                                                              .toString()),
                                                      courseTerm:
                                                          widget.courseTerm,
                                                    )));
                                        print(element);
                                      },
                                      cells: <DataCell>[
                                        DataCell(Text(
                                          widget.courseTerm,
                                          style: TextStyle(
                                            fontSize: textSize,
                                          ),
                                        )),
                                        DataCell(Text(
                                          element["id"].toString(),
                                          style: TextStyle(
                                            fontSize: textSize,
                                          ),
                                        )),
                                        DataCell(Text(
                                          element["full_name"],
                                          style: TextStyle(
                                            fontSize: textSize,
                                          ),
                                        )),
                                        // DataCell(Text(
                                        //   totalAbsents
                                        //       .toString(), //@@@@@@@@@@@@@@@@@@
                                        //   style: TextStyle(
                                        //     fontSize: textSize,
                                        //   ),
                                        // )),
                                        // DataCell(Text(
                                        //   totalAbsents
                                        //       .toString(), //@@@@@@@@@@@@@@@@@@
                                        //   style: TextStyle(
                                        //     fontSize: textSize,
                                        //   ),
                                        // )),
                                        //Extracting from Map element the value
                                        // DataCell(Text(
                                        //   listOfAttendance[listOfStudents
                                        //       .indexOf(element)]["CheckIn"],
                                        //   //         ??
                                        //   //     '-',
                                        //   style: TextStyle(
                                        //     fontSize: textSize,
                                        //   ),
                                        // )),
                                        // DataCell(Text(
                                        //   listOfAttendance[listOfStudents
                                        //       .indexOf(element)]["CheckOut"],
                                        //   //      ??
                                        //   // '-',
                                        //   style: TextStyle(
                                        //     fontSize: textSize,
                                        //   ),
                                        // )),
                                      ],
                                    ),
                                  )
                                  .toList()
                              : tempList
                                  .map(
                                    (element) => DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text(
                                          element["noArgs"] ?? '',
                                          style: TextStyle(
                                            fontSize: textSize,
                                          ),
                                        )),
                                        //Extracting from Map element the value
                                        DataCell(Text(
                                          element["noArgs"] ?? '',
                                          style: TextStyle(
                                            fontSize: textSize,
                                          ),
                                        )),
                                        DataCell(Text(
                                          element["noArgs"] ?? '',
                                          style: TextStyle(
                                            fontSize: textSize,
                                          ),
                                        )),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),

                const SizedBox(
                  height: 20,
                ),

                //Total counter~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                isStudent
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Table(
                            border: TableBorder.all(color: Colors.black26),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: const <int, TableColumnWidth>{
                              0: IntrinsicColumnWidth(),
                              1: IntrinsicColumnWidth(),
                            },
                            children: <TableRow>[
                              TableRow(
                                children: <Widget>[
                                  Container(
                                    height: 32,
                                    width: 120,
                                    color: Colors.green,
                                    child: const Center(
                                      child: Text(
                                        'Total Presents: ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32,
                                    width: 32,
                                    // color: Colors.orange,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 5,
                                        top: 10,
                                      ),
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                            hintText: '$_counterP',
                                            hintStyle: TextStyle(
                                              color: Colors.green,
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  Container(
                                    height: 32,
                                    width: 120,
                                    color: Colors.red,
                                    child: const Center(
                                      child: Text(
                                        'Total Absents: ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32,
                                    width: 32,
                                    // color: Colors.orange,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 5,
                                        top: 10,
                                      ),
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                            hintText: '$_counterA',
                                            hintStyle: TextStyle(
                                              color: Colors.red,
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
