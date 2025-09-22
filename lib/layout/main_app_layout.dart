import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ignousolutionhub/features/user/books_page.dart';
import 'package:ignousolutionhub/features/user/contact_page.dart';
import 'package:ignousolutionhub/features/user/home_page.dart';
import 'package:ignousolutionhub/features/user/question_papers_page.dart';
import 'package:ignousolutionhub/features/user/solved_assignments_page.dart';
import 'package:ignousolutionhub/features/user/study_material_page.dart';
import 'package:ignousolutionhub/responsive/responsive_layout.dart';

class MainAppLayout extends StatefulWidget {
  const MainAppLayout({super.key});

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final List<Widget> _pages = [
    const HomePage(),
    const StudyMaterialPage(),
    const BooksPage(),
    const SolvedAssignmentsPage(),
    const QuestionPapersPage(),
    const ContactPage(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileScaffold(selectedIndex: _selectedIndex, onItemSelected: _onItemSelected, pages: _pages),
      tablet: _TabletScaffold(selectedIndex: _selectedIndex, onItemSelected: _onItemSelected, pages: _pages),
      web: _DesktopScaffold(selectedIndex: _selectedIndex, onItemSelected: _onItemSelected, pages: _pages),
    );
  }
}

// Common Profile Section Widget
Widget _buildProfileSection(BuildContext context, {bool isCollapsed = false}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: isCollapsed
        ? Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(height: 8),
              // Tooltip for collapsed view
              Tooltip(
                message: 'John Doe\njohn.doe@example.com',
                child: Icon(Icons.info_outline, size: 16, color: Colors.grey.shade700),
              ),
            ],
          )
        : Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
  );
}

// Mobile Scaffold with Drawer
class _MobileScaffold extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<Widget> pages;
  const _MobileScaffold({required this.selectedIndex, required this.onItemSelected, required this.pages});

  @override
  State<_MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<_MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IGNOUE SOLUTION HUB'),
      ),
      drawer: _buildDrawer(context),
      body: widget.pages[widget.selectedIndex],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf9f9f9), Color(0xFFe8f5e9)],
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IGNOU SOLUTION HUB',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Study Partner',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.home, 'Home', 0),
            _buildDrawerItem(context, Icons.book, 'Study Material', 1),
            _buildDrawerItem(context, Icons.library_books, 'Books', 2),
            _buildDrawerItem(context, Icons.assignment, 'Solved Assignments', 3),
            _buildDrawerItem(context, Icons.description, 'Question Papers', 4),
            _buildDrawerItem(context, Icons.contact_mail, 'Contact Us', 5),
            const Spacer(),
            _buildProfileSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: widget.selectedIndex == index,
      onTap: () {
        widget.onItemSelected(index);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}

// Tablet Scaffold with fixed sidebar
class _TabletScaffold extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<Widget> pages;
  const _TabletScaffold({required this.selectedIndex, required this.onItemSelected, required this.pages});

  @override
  State<_TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<_TabletScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IGNOU SOLUTION HUB'),
      ),
      body: Row(
        children: [
          _buildSidebar(context, isCollapsed: false), // Fixed sidebar
          Expanded(
            child: widget.pages[widget.selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isCollapsed}) {
    return Container(
      width: isCollapsed ? 70 : 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf9f9f9), Color(0xFFe8f5e9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isCollapsed
                ? Icon(
                    Icons.school,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  )
                : Text(
                    'IGNOU SOLUTION HUB',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
          ),
          const Divider(),
          _buildSidebarItem(context, Icons.home, 'Home', 0, isCollapsed),
          _buildSidebarItem(context, Icons.book, 'Study Material', 1, isCollapsed),
          _buildSidebarItem(context, Icons.library_books, 'Books', 2, isCollapsed),
          _buildSidebarItem(context, Icons.assignment, 'Solved Assignments', 3, isCollapsed),
          _buildSidebarItem(context, Icons.description, 'Question Papers', 4, isCollapsed),
          _buildSidebarItem(context, Icons.contact_mail, 'Contact Us', 5, isCollapsed),
          const Spacer(),
          _buildProfileSection(context, isCollapsed: isCollapsed),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title, int index, bool isCollapsed) {
    return ListTile(
      leading: Icon(icon),
      title: isCollapsed ? null : Text(title),
      selected: widget.selectedIndex == index,
      onTap: () {
        widget.onItemSelected(index);
      },
    );
  }
}

// Desktop Scaffold with fixed sidebar
class _DesktopScaffold extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<Widget> pages;
  const _DesktopScaffold({required this.selectedIndex, required this.onItemSelected, required this.pages});

  @override
  State<_DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<_DesktopScaffold> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IGNOU SOLUTION HUB'),
        leading: IconButton(
          icon: Icon(_isSidebarCollapsed ? Icons.menu_open : Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarCollapsed = !_isSidebarCollapsed;
            });
          },
        ),
      ),
      body: Row(
        children: [
          _buildSidebar(context, isCollapsed: _isSidebarCollapsed), // Fixed sidebar
          Expanded(
            child: widget.pages[widget.selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isCollapsed}) {
    return Container(
      width: isCollapsed ? 70 : 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf9f9f9), Color(0xFFe8f5e9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isCollapsed
                ? Icon(
                    Icons.school,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  )
                : Text(
                    'IGNOUE SOLUTION HUB',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
          ),
          const Divider(),
          _buildSidebarItem(context, Icons.home, 'Home', 0, isCollapsed),
          _buildSidebarItem(context, Icons.book, 'Study Material', 1, isCollapsed),
          _buildSidebarItem(context, Icons.library_books, 'Books', 2, isCollapsed),
          _buildSidebarItem(context, Icons.assignment, 'Solved Assignments', 3, isCollapsed),
          _buildSidebarItem(context, Icons.description, 'Question Papers', 4, isCollapsed),
          _buildSidebarItem(context, Icons.contact_mail, 'Contact Us', 5, isCollapsed),
          const Spacer(),
          _buildProfileSection(context, isCollapsed: isCollapsed),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String title, int index, bool isCollapsed) {
    return ListTile(
      leading: Icon(icon),
      title: isCollapsed ? null : Text(title),
      selected: widget.selectedIndex == index,
      onTap: () {
        widget.onItemSelected(index);
      },
    );
  }
}