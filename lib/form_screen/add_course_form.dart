import 'dart:convert';
import 'dart:math';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCourseForm extends StatefulWidget {
  final String courseId;

  const AddCourseForm({Key? key, required this.courseId}) : super(key: key);

  @override
  State<AddCourseForm> createState() => _AddCourseFormState();
}

class _AddCourseFormState extends State<AddCourseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _nameTextController = TextEditingController();
  // ---------------------------Shared Preference----------------------
  String? musicsString = '';
  late List<Music> musics;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String saveString = '';
  write() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('musics_key', saveString).then((value) async {
      await read();
    }).catchError((e) {
      print(e);
    });
    print('Data Set');
    print('Added data');
  }

  read() async {
    final SharedPreferences prefs = await _prefs;

    musicsString = prefs.getString('musics_key');
    print('Data Get');
    musics = Music.decode(musicsString!);
    for (int i = 0; i < musics.length; i++) {
      print(musics[i].id.toString());
      print(musics[i].course_name);
      print(musics[i].course_day);
      print(musics[i].course_start_time);
    }
  }

  update() async {
    final SharedPreferences prefs = await _prefs;
    musicsString = prefs.getString('musics_key');
    print('Data Get');
    final List<Music> musics = Music.decode(musicsString!);
    musics.add(Music(
        id: '',
        course_day: '',
        course_name: '',
        course_end_time: '',
        course_start_time: '',
        course_term: ''));
    for (int i = 0; i < musics.length; i++) {
      print(musics[i].id.toString());
      print(musics[i].course_name);
      print(musics[i].course_day);
    }
  }

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _course =
      FirebaseFirestore.instance.collection('courses');
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.fromDateTime(
      DateTime.now().add(Duration(hours: 3, minutes: 30)));

  String _courseDay = 'Monday';

  String _courseStartTime = '';
  String _courseEndTime = '';

  String _courseTerm = 'Summer 2022';

  // int _generatedId = Random().nextInt(99) + 105400;
  late int _generatedId;

  var _courseName = '';

  void _trySubmit() {
    
    final isValid = _formKey.currentState!.validate();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.reset();

    //Update record~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (widget.courseId != '' || !widget.courseId.isEmpty) {
      _course.doc("${widget.courseId}").update({
        'course_name': _courseName,
        'course_day': _courseDay,
        'course_start_time': startTime.format(context).toString(),
        'course_end_time': endTime.format(context).toString(),
        'course_term': _courseTerm,
      }).then((value) async {
        
        print("Course updated");
        
        EasyLoading.showSuccess('Course updated');
        _nameTextController.text = "";
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }).catchError((error) {
        print("Failed to add user: $error");
        EasyLoading.showSuccess('Failed to update record');
      });
    }
    //Add record~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (isValid && widget.courseId == '') {
      _course.doc("$_generatedId").set({
        'id': _generatedId,
        'course_name': _courseName,
        'course_day': _courseDay,
        'course_start_time': startTime.format(context).toString(),
        'course_end_time': endTime.format(context).toString(),
        'course_term': _courseTerm,
      }).then((value) async {
        saveString = Music.encode([
          Music(
            id: _generatedId.toString(),
            course_day: _courseDay,
            course_name: _courseName,
            course_end_time: endTime.format(context).toString(),
            course_start_time: startTime.format(context).toString(),
            course_term: _courseTerm,
          )
        ]);
        await write();
        
        print("Course Added");
        EasyLoading.showSuccess('Course saved');
        _generatedId = Random().nextInt(99) + 105400;
      }).catchError((error) async {
        print("Failed to add course: $error");
        EasyLoading.showSuccess('Failed to saved record');
        
      });
    }
  }

  final CollectionReference _coursenum =
      FirebaseFirestore.instance.collection('courses');
  List<Map<String, dynamic>> listOfCourse = [];
  @override
  void initState() {
    
    openHiveDB();

    // get course list.........................
    // if (Hive.box('loginCredentials').get('role').toString() == 'admin') {
    _coursenum.get().then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        setState(() {
          listOfCourse.add(data);
        });
        print(data['course_name']);
      });
    }).whenComplete(() {
      EasyLoading.dismiss();
      _generatedId = 105500 + 1 + listOfCourse.length;
      print(_generatedId);
    });
    // } else {
    //   getElectedCourses();
    // }

    //if updating course~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (widget.courseId != '' || !widget.courseId.isEmpty) {
      super.initState();
      EasyLoading.show(
        status: 'Loading...',
        indicator: CircularProgressIndicator(),
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );

      _course.doc('${widget.courseId}').get().then((value) {
        Map<String, dynamic> data = value.data()! as Map<String, dynamic>;
        setState(() {
          _nameTextController.text = data['course_name'];
          _courseDay = data['course_day'];
          _courseStartTime = data['course_start_time'];
          _courseEndTime = data['course_end_time'];
          _courseTerm = data['course_term'];
        });

        TimeOfDay stringToTimeOfDay(String tod) {
          final format = DateFormat.jm(); //"6:00 AM"
          return TimeOfDay.fromDateTime(format.parse(tod));
        }

        print(stringToTimeOfDay(_courseStartTime));
        startTime = stringToTimeOfDay(_courseStartTime);
        endTime = stringToTimeOfDay(_courseEndTime);
        print(data['course_name']);
      }).whenComplete(() => EasyLoading.dismiss());
    }
  }

  Future selectedTime(BuildContext context, bool ifPickedTime,
      TimeOfDay initialTime, Function(TimeOfDay) onTimePicked) async {
    var _pickedTime =
        await showTimePicker(context: context, initialTime: initialTime);
    if (_pickedTime != null) {
      onTimePicked(_pickedTime);
    }
  }

  Widget _buildTimePick(String title, bool ifPickedTime, TimeOfDay currentTime,
      Function(TimeOfDay) onTimePicked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: GestureDetector(
            child: Text(
              currentTime.format(context),
            ),
            onTap: () {
              selectedTime(context, ifPickedTime, currentTime, onTimePicked);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  widget.courseId == '' || widget.courseId.isEmpty
                      ? Container()
                      : Text('Updating ID: ' + widget.courseId),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Coure Name: "),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: TextFormField(
                          controller: _nameTextController,
                          key: ValueKey('name'),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          decoration:
                              const InputDecoration(labelText: 'Course Name'),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            value = value!.trim();
                            if (value.isEmpty) {
                              return 'Please enter a name.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _courseName = value.toString().trim();
                          },
                        ),
                      ),
                    ],
                  ),

                  //Student Name~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                  const SizedBox(
                    height: 20,
                  ),

                  //Select Course~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Select Day: "),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: DropdownButton<String>(
                          value: _courseDay,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,

                          isExpanded: true,
                          // menuMaxHeight: 200,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _courseDay = newValue!;
                            });
                          },
                          items: <String>[
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildTimePick("Start Time", true, startTime, (x) {
                    setState(() {
                      startTime = x;
                      print("The picked time is: $x");
                    });
                  }),
                  const SizedBox(height: 10),
                  _buildTimePick("End Time", true, endTime, (x) {
                    setState(() {
                      endTime = x;
                      print("The picked time is: $x");
                    });
                  }),
                  //Select Course~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text("Select Time Slot: "),
                  //     Container(
                  //        width: MediaQuery.of(context).size.width/2,
                  //       child: DropdownButton<String>(
                  //         value: _courseTime,
                  //         icon: const Icon(Icons.arrow_downward),
                  //         iconSize: 24,
                  //         elevation: 16,

                  //         isExpanded: true,
                  //         // menuMaxHeight: 200,
                  //         style: const TextStyle(color: Colors.black),
                  //         underline: Container(
                  //           height: 2,
                  //           color: Theme.of(context).primaryColor,
                  //         ),
                  //         onChanged: (String? newValue) {
                  //           setState(() {
                  //             _courseTime = newValue!;
                  //           });
                  //         },
                  //         items: <String>[
                  //           '8:40 AM - 11:40 AM',
                  //           '12:30 PM - 03:30 PM',
                  //         ].map<DropdownMenuItem<String>>((String value) {
                  //           return DropdownMenuItem<String>(
                  //             value: value,
                  //             child: Text(value),
                  //           );
                  //         }).toList(),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Select Course~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Select Term: "),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: DropdownButton<String>(
                          value: _courseTerm,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          isExpanded: true,
                          // menuMaxHeight: 200,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _courseTerm = newValue!;
                            });
                          },
                          items: <String>[
                            'Spring 2022',
                            'Summer 2022',
                            'Fall 2022',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                        child: Container(
                          child: const Text(
                            "Save Course",
                            style: TextStyle(fontSize: 20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                        ),
                        onPressed: _trySubmit,
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openHiveDB() async {
    await Hive.openBox('loginCredentials');
  }
}

class Music {
  final String id;
  final String course_day;
  final String course_name;
  final String course_end_time;
  final String course_start_time;
  final String course_term;

  Music({
    required this.id,
    required this.course_day,
    required this.course_name,
    required this.course_end_time,
    required this.course_start_time,
    required this.course_term,
  });

  factory Music.fromJson(Map<String, dynamic> jsonData) {
    return Music(
        id: jsonData['id'].toString(),
        course_day: jsonData['course_day'],
        course_end_time: jsonData['course_end_time'],
        course_name: jsonData['course_name'],
        course_start_time: jsonData['course_start_time'],
        course_term: jsonData['course_term']);
  }

  static Map<String, dynamic> toMap(Music music) => {
        'id': music.id,
        'course_day': music.course_day,
        'course_name': music.course_name,
        'course_end_time': music.course_end_time,
        'course_start_time': music.course_start_time,
        'course_term': music.course_term,
      };

  static String encode(List<Music> musics) => json.encode(
        musics
            .map<Map<String, dynamic>>((music) => Music.toMap(music))
            .toList(),
      );

  static List<Music> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Music>((item) => Music.fromJson(item))
          .toList();
  @override
  String toString() {
    return 'Music{id: $id,course_day: $course_day,course_name: $course_name,course_end_time: $course_end_time,course_start_time: $course_start_time,course_term: $course_term}';
  }
}
