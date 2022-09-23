import 'package:flutter/material.dart';

class StudentViewCard extends StatelessWidget {
  final String teacherName, userName;
  final GestureTapCallback onPressedDelete;
  final GestureTapCallback onPressedUpdate;

  const StudentViewCard({
    Key? key,
    required this.teacherName,
    required this.userName,
    required this.onPressedDelete,
    required this.onPressedUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(teacherName),
        subtitle: Text(userName),
        trailing: SizedBox(
          width: 120,
          child: Row(
            children: [
              GestureDetector(
                onTap: onPressedUpdate,
                child: Card(
                  elevation: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onPressedDelete,
                child: const Card(
                  elevation: 1.0,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
