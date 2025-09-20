import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WELCOME TO IGNOU SOLUTION HUB',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your one-stop solution for IGNOU study materials.',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Quick Links
            Text(
              'QUICK LINKS',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, // Responsive grid
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildQuickLinkCard(context, 'Study Material', Icons.book, '/study_material'),
                _buildQuickLinkCard(context, 'Books', Icons.library_books, '/books'),
                _buildQuickLinkCard(context, 'Assignments', Icons.assignment, '/solved_assignments'),
                _buildQuickLinkCard(context, 'Question Papers', Icons.description, '/question_papers'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
