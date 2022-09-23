import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'profile_icon_card.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TeacherProfile extends StatefulWidget {
  final IconData iconData;

  const TeacherProfile({Key? key, required this.iconData}) : super(key: key);

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  // Create a CollectionReference called users that references the firestore collection
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Map<String, dynamic> teacherInfo = {};

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
    int? teacherId =
        int.tryParse(Hive.box('loginCredentials').get('id').toString());
    print(teacherId);
    if (Hive.box('loginCredentials').isOpen) {
      _users.where('id', isEqualTo: teacherId).limit(1).get().then((value) {
        print(value.size);
        value.docs.forEach((doc) {
          print(doc.exists);
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          setState(() {
            teacherInfo = data;
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
          "Full Name: ${teacherInfo['name'] ?? ""}",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          "Username: ${teacherInfo['username'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 15,
        ),

        Text(
          "Mobile: ${teacherInfo['number'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 15,
        ),
        Text(
          "Email: ${teacherInfo['email'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(
          height: 15,
        ),
        Text(
          "CNIC: ${teacherInfo['nic'] ?? ""}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> openHiveDB() async {
    await Hive.openBox('loginCredentials');
  }
}
