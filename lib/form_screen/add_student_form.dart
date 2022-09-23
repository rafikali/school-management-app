import 'dart:math';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multiselect/multiselect.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class AddStudentForm extends StatefulWidget {
  final String studentId;

  const AddStudentForm({Key? key, required this.studentId}) : super(key: key);

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _userNameTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _numberTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _guardianNameTextController = TextEditingController();
  final _guardianNumberTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmPasswordTextController = TextEditingController();

  List<String> _courseName = [];
  List<String> _courseId = [];

  String fingerIconStatus = 'initial';

  //For Fingerprint Sensor~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference deviceRef;
  late DatabaseReference userRef;

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  // final CollectionReference ui =
  //     FirebaseFirestore.instance.collection('users').doc(uid);

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _courses =
      FirebaseFirestore.instance.collection('courses');

  List<String> _selectedCourses = [];

  // ###########################
  final CollectionReference _usersnum =
      FirebaseFirestore.instance.collection('users');

  final List<Map<String, dynamic>> listOfStudents = [];

  // int _generatedId = Random().nextInt(99) + 9000;
  late int _generatedId;

  var _username,
      _full_name,
      _number,
      _email,
      _guardian_name,
      _guardian_number,
      _password;
  TwilioFlutter? twilioFlutter;

  @override
  void initState() {
    super.initState();

    twilioFlutter = TwilioFlutter(
        accountSid: 'ACe2dea17b47690167d76369b4fa0bf1e0',
        authToken: 'e491a260522f7ad5781f3c6bbcc5a132',
        twilioNumber: '+19378575801');
    //to fill-up data of dropdown~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    // get list of students.....................
    _usersnum.where('role', isEqualTo: 'student').get().then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        setState(() {
          listOfStudents.add(data);
        });
        print(data['full_name']);
        // print(data.length);
        // print(listOfStudents.length);
        // print();
      });
    }).whenComplete(() {
      EasyLoading.dismiss();
      _generatedId = 9100 + 1 + listOfStudents.length;
      print(_generatedId);
    });

    _courses.get().then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        setState(() {
          _courseName.add(data['course_name'].toString());
          _courseId.add(data['id'].toString());
        });
        print(data['course_name']);
      });
    }).whenComplete(() => EasyLoading.dismiss());

    //if updating teacher~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (widget.studentId != '' || !widget.studentId.isEmpty) {
      super.initState();
      EasyLoading.show(
        status: 'Loading...',
        indicator: CircularProgressIndicator(),
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );

      _users.doc('${widget.studentId}').get().then((value) {
        Map<String, dynamic> data = value.data()! as Map<String, dynamic>;
        setState(() {
          _userNameTextController.text = data['username'];
          _nameTextController.text = data['full_name'];
          _numberTextController.text = data['number'];
          _emailTextController.text = data['email'];
          _guardianNameTextController.text = data['guardian_name'];
          _guardianNumberTextController.text = data['guardian_number'];
          _passwordTextController.text = data['password'];
          for (final element in data['courses']) {
            _selectedCourses.add(element);
          }
        });
      }).whenComplete(() => EasyLoading.dismiss());
    }
  }

  Future<void> activateDevice() async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    setState(() {
      fingerIconStatus = 'pending';
    });

    var id = widget.studentId != '' ? widget.studentId : _generatedId;
    var name =
        _nameTextController.text != '' ? _nameTextController.text : _full_name;

    DatabaseEvent nodeCount = await database.ref('users').once();
    String f_ID = (nodeCount.snapshot.children.length + 1).toString();

    deviceRef = database.ref("device");
    userRef = database.ref("users/$f_ID");

    await userRef.set({
      "id": "$id",
      "f_id": "$f_ID",
      "name": "$name",
      "registration_status": "false",
    });

    await deviceRef.set({
      "id": "$f_ID",
      "state": "true",
    });

    // Get the Stream
    Stream<DatabaseEvent> stream = deviceRef.onValue;

    // Subscribe to the streaming
    stream.listen((DatabaseEvent event) {
      print('Snapshot: ${event.snapshot.value}'); // DataSnapshot
      if (event.snapshot.value.toString().contains('false')) {
        setState(() {
          fingerIconStatus = 'success';
        });
      }
    }).onError((error) {
      setState(() {
        fingerIconStatus = 'error';
      });
    });
  }

  void sendSms() async {
    twilioFlutter!.sendSMS(
        toNumber: '+923212069641',
        messageBody:
            'AMS ALERT !!! Dear Guardian Student ${_full_name} has been registerd.\n Login credentials are (Username: ${_username} Password: ${_password})');
  }

  void getSms() async {
    var data = await twilioFlutter!.getSmsList();
    print(data);
    await twilioFlutter!.getSMS('***************************');
  }

  void _trySubmit() {
    
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    if (_selectedCourses.isEmpty) {
      EasyLoading.showError('select course');
      return;
    }

    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();

    //Update record~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (widget.studentId != '' || !widget.studentId.isEmpty) {
      // _formKey.currentState!.reset();
      _users.doc("${widget.studentId}").update({
        'username': _username,
        'full_name': _full_name,
        'number': _number,
        'email': _email,
        'guardian_name': _guardian_name,
        'guardian_number': _guardian_number,
        'courses': _selectedCourses,
        'password': _password,
      }).then((value) {
        print("Course Added");
        EasyLoading.showSuccess('Record updated');

        _nameTextController.text = "";
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }).catchError((error) {
        print("Failed to add user: $error");
        EasyLoading.showSuccess('Failed to update record');
      });
    }
    print(isValid);
    print(widget.studentId);

    //Add record~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (isValid && widget.studentId == '') {
      // _formKey.currentState!.reset();
      sendSms();
      //Getting usernames
      _users
          .where('username', isEqualTo: _username)
          .limit(1)
          .get()
          .then((value) {
        print(value.size);
        if (value.size == 0) {
          _users.doc("$_generatedId").set({
            'id': _generatedId,
            'full_name': _full_name,
            'username': _username,
            'number': _number,
            'email': _email,
            'guardian_name': _guardian_name,
            'guardian_number': _guardian_number,
            'courses': _selectedCourses,
            'password': _password,
            'role': 'student',
          }).then((value) async {
            
            print("User Added");
            EasyLoading.showSuccess('Record saved');
            _generatedId = Random().nextInt(99) + 9000;
            Navigator.of(context).pop();
          }).catchError((error) {
            print("Failed to add user: $error");
            EasyLoading.showSuccess('Failed to saved record');
          });
        } else {
          EasyLoading.showError('Username already exists');
        }
        // print(data['teacher_name']);
      });
    }
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

                  widget.studentId == '' || widget.studentId.isEmpty
                      ? Container()
                      : Text('Updating ID: ' + widget.studentId),

                  //Student username~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _userNameTextController,
                    key: const ValueKey('S_userName'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Student username'),
                    keyboardType: TextInputType.text,
                    maxLength: 10,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a username.';
                      }
                      if (value.contains(' ')) {
                        return 'Please enter a valid/without spaces.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _username = value.toString().trim();
                    },
                  ),

                  //Student Name~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _nameTextController,
                    key: const ValueKey('S_name'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Student full name'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a full name.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _full_name = value.toString().trim();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //Student Number~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _numberTextController,
                    key: const ValueKey('S_number'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Mobile Number'),
                    keyboardType: TextInputType.text,
                    maxLength: 13,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a phone number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _number = value.toString().trim();
                    },
                  ),

                  //Student Email~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _emailTextController,
                    key: const ValueKey('S_email'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Student Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter an email.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value.toString().trim();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //Guardian Name~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _guardianNameTextController,
                    key: const ValueKey('S_guardianName'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Guardian Name'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a guardian name.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _guardian_name = value.toString().trim();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //Guardian Number~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _guardianNumberTextController,
                    key: const ValueKey('S_GuardianNumber'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                        labelText: 'Guardian Mobile Number'),
                    keyboardType: TextInputType.text,
                    maxLength: 13,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a guardian mobile number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _guardian_number = value.toString().trim();
                    },
                  ),

                  //Select Course~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  DropDownMultiSelect(
                    onChanged: (List<String> x) {
                      setState(() {
                        _selectedCourses = x;
                      });
                    },
                    options: _courseName,
                    selectedValues: _selectedCourses,
                    whenEmpty: 'Select Course',
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  //Password~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _passwordTextController,
                    key: const ValueKey('password'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    // decoration: const InputDecoration(labelText: 'password'),
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),

                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a password.';
                      }
                      if (value.length <= 3) {
                        return 'Please enter a valid password.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value.toString().trim();
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //Confirm Password~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _confirmPasswordTextController,
                    key: const ValueKey('ConfirmPassword'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Confirm Password'),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a Confirm password.';
                      }
                      if (_passwordTextController.value.text != value) {
                        return 'password not match.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  //Fingerprint~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  const Text("Click here and place your finger at machine "),
                  const SizedBox(
                    height: 15,
                  ),
                  Card(
                    child: fingerIconStatus == "initial"
                        ? IconButton(
                            icon: Icon(Icons.fingerprint),
                            iconSize: 80,
                            onPressed: activateDevice,
                          )
                        : fingerIconStatus == "pending"
                            ? Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: CircularProgressIndicator(),
                              )
                            : fingerIconStatus == "success"
                                ? IconButton(
                                    icon: Icon(Icons.done_outline_rounded),
                                    iconSize: 80,
                                    onPressed: activateDevice,
                                  )
                                : IconButton(
                                    icon: Icon(Icons.error_outline_rounded),
                                    iconSize: 80,
                                    onPressed: activateDevice,
                                  ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),
                  fingerIconStatus == "success"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            MaterialButton(
                              child: Container(
                                child: Text(
                                  widget.studentId == '' ||
                                          widget.studentId.isEmpty
                                      ? "Generate ID"
                                      : "Save Record",
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
                        )
                      : Container(),
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
}
