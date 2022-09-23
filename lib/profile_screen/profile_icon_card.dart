import 'package:flutter/material.dart';


class ProfileIconCard extends StatelessWidget {

  final IconData iconData;
  const ProfileIconCard({Key? key, required this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: const EdgeInsets.all(50),
        width: double.infinity,
        alignment: Alignment.center,
        child: Icon(
          iconData,
          size: 100,
        ),
      ),
      shape: const CircleBorder(
        side: BorderSide(
          width: 2,
        ),
      ),
    );
  }
}
