import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'profile_icon_card.dart';

class StudentProfile extends StatefulWidget {
  final IconData iconData;

  const StudentProfile({Key? key, required this.iconData}) : super(key: key);

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Map<String, dynamic> studentInfo = {};

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
    int? studentId =
        int.tryParse(Hive.box('loginCredentials').get('id').toString());
    print(studentId);
    if (Hive.box('loginCredentials').isOpen) {
      _users.where('id', isEqualTo: studentId).limit(1).get().then((value) {
        print(value.size);
        value.docs.forEach((doc) {
          print(doc.exists);
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          setState(() {
            studentInfo = data;
          });
          print(data['teacher_name']);
        });
      }).whenComplete(() => EasyLoading.dismiss());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileIconCard(
          iconData: widget.iconData,
        ),
        const SizedBox(
          height: 30,
        ),

        const Text(
          "Personal Information",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        //Draw a line~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Container(
          color: Theme.of(context).backgroundColor,
          height: 2,
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          "Full Name: ${studentInfo['full_name'] ?? ""}",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Username: ${studentInfo['username'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Mobile: ${studentInfo['number'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Email: ${studentInfo['email'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Guardian Name: ${studentInfo['guardian_name'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Guardian Mobile: ${studentInfo['guardian_number'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Student ID: ${studentInfo['id'] != null ? studentInfo['id'].toString().substring(0, 4) : ""}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<void> openHiveDB() async {
    await Hive.openBox('loginCredentials');
  }
}
