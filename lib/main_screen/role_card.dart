import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {

  final IconData iconData;
  final String role;
  final GestureTapCallback onPressed;

  RoleCard({Key? key, required this.iconData, required this.role, required this.onPressed}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        splashColor: Theme.of(context).backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            children: [
              Icon(iconData, size: 50,),
              const SizedBox(height: 10,),
              Text(role)
            ],
          ),
        ),
      ),
    );
  }
}
