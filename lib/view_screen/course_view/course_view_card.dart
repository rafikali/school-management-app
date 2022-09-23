import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourseViewCard extends StatelessWidget {
  final int Id;
  final String courseName, courseDay, courseStartTime, courseEndTime;
  final String role;
  final GestureTapCallback onPressedDelete;
  final GestureTapCallback onPressedUpdate;

  const CourseViewCard({
    Key? key,
    required this.Id,
    required this.courseName,
    required this.courseDay,
    required this.courseStartTime,
    required this.courseEndTime,
    required this.role,
    required this.onPressedDelete,
    required this.onPressedUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // contentPadding: EdgeInsets.only(top: 10, bottom: 10),
        title: Text('$Id - '+courseName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$courseDay ( $courseStartTime - $courseEndTime )'),
            // Text(
            //   'Course ID: $Id',
            //   style: TextStyle(color: Colors.red),
            // ),
            // Container(
            //   height: 2,
            //   width: double.infinity,
            //   color: Theme.of(context).primaryColor,
            // ),
          ],
        ),
        trailing: SizedBox(
          width: 120,
          child: role == "Admin Course"
              ? Row(
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
                )
              : Container(),
        ),
      ),
    );
  }
}
