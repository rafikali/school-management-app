import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profile_icon_card.dart';

class AdminProfile extends StatelessWidget {
  final IconData iconData;

  const AdminProfile({Key? key, required this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileIconCard(
          iconData: iconData,
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
          "Name: Admin",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 15,
        ),
        const Text(
          "Password: 12345",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
