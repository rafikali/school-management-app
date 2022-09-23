import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multiselect/multiselect.dart';

class AddTeacherForm extends StatefulWidget {
  final String teacherId;

  const AddTeacherForm({Key? key, required this.teacherId}) : super(key: key);

  @override
  State<AddTeacherForm> createState() => _AddTeacherFormState();
}

class _AddTeacherFormState extends State<AddTeacherForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _userNameTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _numberTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _nicTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmPasswordTextController = TextEditingController();

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _courses =
      FirebaseFirestore.instance.collection('courses');

  var _username, _name, _number, _email, _nic, _password;

  List<String> _selectedCourses = [];

  List<String> _courseName = [];
  List<String> _courseId =
      []; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  int _generatedId = Random().nextInt(100000) + 100000;

  @override
  void initState() {
    super.initState();

    //to fill-up data of dropdown~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    _courses.get().then((value) {
      value.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        setState(() {
          _courseName.add(data['course_name'].toString());
          _courseId.add(data['id'].toString());
        });
      });
    }).whenComplete(() => EasyLoading.dismiss());

    //if updating teacher~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (widget.teacherId != '' || !widget.teacherId.isEmpty) {
      super.initState();
      EasyLoading.show(
        status: 'Loading...',
        indicator: CircularProgressIndicator(),
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );

      _users.doc('${widget.teacherId}').get().then((value) {
        Map<String, dynamic> data = value.data()! as Map<String, dynamic>;
        setState(() {
          _userNameTextController.text = data['username'];
          _nameTextController.text = data['name'];
          _numberTextController.text = data['number'];
          _emailTextController.text = data['email'];
          _nicTextController.text = data['nic'];
          _passwordTextController.text = data['password'];
          for (final element in data['courses']) {
            _selectedCourses.add(element);
          }
        });
      }).whenComplete(() => EasyLoading.dismiss());
    }
  }

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCourses.isEmpty) {
      EasyLoading.showError('select course');
      return;
    }

    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();

    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );

    //Update record~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (widget.teacherId != '' || !widget.teacherId.isEmpty) {
      // _formKey.currentState!.reset();
      _users.doc("${widget.teacherId}").update({
        'username': _username,
        'name': _name,
        'number': _number,
        'email': _email,
        'nic': _nic,
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

    //Add record~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (isValid && widget.teacherId == '') {
      // _formKey.currentState!.reset();

      //Getting usernames
      _users
          .where('username', isEqualTo: _username)
          .limit(1)
          .get()
          .then((value) {
        print('doc size: ' + value.size.toString());
          if (value.size == 0) {
            //if Username not Exist
            _users.doc("$_generatedId").set({
              'id': _generatedId,
              'username': _username,
              'name': _name,
              'number': _number,
              'email': _email,
              'nic': _nic,
              'courses': _selectedCourses,
              'password': _password,
              'role': 'teacher',
            }).then((value) {
              print("teacher Added");
              EasyLoading.showSuccess('Record saved');
              // _generatedId = Random().nextInt(100000) + 100000;
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

                  widget.teacherId == '' || widget.teacherId.isEmpty
                      ? Container()
                      : Text('Updating ID: ' + widget.teacherId),

                  //Teacher username~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _userNameTextController,
                    key: const ValueKey('T_userName'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Teacher username'),
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

                  //Teacher Name~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _nameTextController,
                    key: const ValueKey('T_name'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Teacher Name'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a name.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value.toString().trim();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //Teacher Number~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _numberTextController,
                    key: const ValueKey('T_number'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Teacher Cell Number'),
                    keyboardType: TextInputType.number,
                    maxLength: 11,
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

                  //Teacher Email~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _emailTextController,
                    key: const ValueKey('T_email'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Teacher Email'),
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
                    height: 20,
                  ),

                  //Teacher NIC~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _nicTextController,
                    key: const ValueKey('T_nic'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration:
                        const InputDecoration(labelText: 'Teacher CNIC'),
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a cnic without dashes.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _nic = value.toString().trim();
                    },
                  ),
                  const SizedBox(
                    height: 20,
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
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                        child: Container(
                          child: const Text(
                            "Save Record",
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
}
