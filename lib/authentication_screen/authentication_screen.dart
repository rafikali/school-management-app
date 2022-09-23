import 'package:biometric_attendance_system/dashboard_screen/dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthenticationScreen extends StatefulWidget {
  static String routeName = "AuthenticationScreen";

  final IconData iconData;
  final String role;

  const AuthenticationScreen(
      {Key? key, required this.iconData, required this.role})
      : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmPasswordTextController = TextEditingController();

  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  bool _showPassword = true;

  var box;
  var _username, _password;

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();


    if (isValid) {
      _formKey.currentState!.reset();
      if (widget.role == 'Teacher') {
        showProgress();
        print("Role is Teacher");
        _users
            .where('username', isEqualTo: _username)
            .where('password', isEqualTo: _password)
            .limit(1)
            .get()
            .then((value) {
          print(value.size);
          if (value.size == 0) {
            print("Invalid Credentials");
            EasyLoading.showError('Wrong Credentials');
          } else {
            value.docs.forEach((doc) {
              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

              if (data['username'] == _username.toString()) {
                box.put('id', data['id'].toString());
                loginNow();
                box.put('role', 'teacher');
                print("Login Teacher: " +
                    _username.toString() +
                    " with id: " +
                    box.get('id'));
              }
              // print(data['teacher_name']);
            });
          }
        }).whenComplete(() => EasyLoading.dismiss());
      }
      if (widget.role == 'Student') {
        showProgress();
        print("Role is Student");
        _users
            .where('username', isEqualTo: _username)
            .where('password', isEqualTo: _password)
            .limit(1)
            .get()
            .then((value) {
          if (value.size == 0) {
            EasyLoading.showError('Wrong Credentials');
          } else {
            value.docs.forEach((doc) {
              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
              if (data['username'] == _username.toString()) {
                box.put('id', data['id'].toString());
                box.put('role', 'student');
                loginNow();
                print("Login Student: " + data['username'].toString());
              } else {
                EasyLoading.showError('Wrong Credentials');
              }
              // print(data['teacher_name']);
            });
          }
        }).whenComplete(() => EasyLoading.dismiss());
      }

      if (widget.role == 'Admin') {
        box.put('role', 'admin');
        loginNow();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    openHiveDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 220,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        // elevation: 0,
        title: Text(
          widget.role.toString() + ' Login',
          style: const TextStyle(fontSize: 30),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Icon(
              widget.iconData,
              size: 50,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),

                  //Username~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  TextFormField(
                    controller: _emailTextController,
                    key: const ValueKey('username'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    decoration: const InputDecoration(labelText: 'username'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter an username.';
                      }
                      if (value != 'admin' && widget.role == "Admin") {
                        return 'Please enter a valid username.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _username = value.toString().trim();
                    },
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
                    obscureText: _showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffix: InkWell(
                        onTap: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        child: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),

                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter a password.';
                      }
                      if (value != '12345' && widget.role=="Admin") {
                        return 'Please enter a valid password.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value.toString().trim();
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
                            "Login",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openHiveDB() async {
    box = await Hive.openBox('loginCredentials');
  }

  void showProgress() {
    EasyLoading.show(
      status: 'Loading...',
      indicator: CircularProgressIndicator(),
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
  }

  void loginNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DashboardScreen(iconData: widget.iconData, role: widget.role),
      ),
    );
  }
}
