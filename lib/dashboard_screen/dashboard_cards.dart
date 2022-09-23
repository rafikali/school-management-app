import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData iconData;
  final String text;
  final GestureTapCallback onPressed;

  DashboardCard(
      {Key? key,
      required this.iconData,
      required this.text,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        splashColor: Theme.of(context).backgroundColor,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            minWidth: 150.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  iconData,
                  size: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(text)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
