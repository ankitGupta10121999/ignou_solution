import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionPapersPage extends StatelessWidget {
  const QuestionPapersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUESTION PAPERS',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildQuestionPaperTable(context),
        ],
      ),
    );
  }

  Widget _buildQuestionPaperTable(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
          },
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: [
                _buildTableHeaderCell('Subject', context),
                _buildTableHeaderCell('Year', context),
                _buildTableHeaderCell('Action', context),
              ],
            ),
            _buildTableRow(context, 'Subject 1', '2023'),
            _buildTableRow(context, 'Subject 2', '2023'),
            _buildTableRow(context, 'Subject 1', '2022'),
            _buildTableRow(context, 'Subject 3', '2022'),
            _buildTableRow(context, 'Subject 2', '2021'),
          ],
        ),
      ),
    );
  }

  TableCell _buildTableHeaderCell(String text, BuildContext context) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, String subject, String year) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(subject),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(year),
          ),
        ),
        TableCell(
          child: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading \'$subject $year Paper\'')),
              );
            },
          ),
        ),
      ],
    );
  }
}