import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SolvedAssignmentsPage extends StatelessWidget {
  const SolvedAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOLVED ASSIGNMENTS',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildAssignmentGroup(context, 'Subject A', '2023'),
          _buildAssignmentGroup(context, 'Subject A', '2022'),
          _buildAssignmentGroup(context, 'Subject B', '2023'),
          _buildAssignmentGroup(context, 'Subject C', '2021'),
        ],
      ),
    );
  }

  Widget _buildAssignmentGroup(BuildContext context, String subject, String year) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
        title: Text(
          '$subject - $year',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        children: [
          _buildAssignmentItem(context, 'Assignment 1'),
          _buildAssignmentItem(context, 'Assignment 2'),
          _buildAssignmentItem(context, 'Assignment 3'),
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(BuildContext context, String assignmentName) {
    return ListTile(
      leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
      title: Text(assignmentName),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloading \'$assignmentName\'')),
          );
        },
      ),
    );
  }
}