import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectsPage extends StatefulWidget {
  final String? courseId;

  const SubjectsPage({super.key, this.courseId});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseId == null
            ? 'All Subjects'
            : 'Subjects for Course'
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .where('courseIds', arrayContains: widget.courseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final subjects = snapshot.data!.docs;
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final doc = subjects[index];
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(doc['courseIds'].join(', ')),
              );
            },
          );
        },
      ),
    );
  }
}
