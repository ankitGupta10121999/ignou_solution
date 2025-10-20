import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/appRouter_constants.dart';
import '../features/user/profile_card_widget.dart';
import '../responsive/responsive_layout.dart';

class AdminAppLayout extends StatefulWidget {
  final Widget child;
  final int index;

  const AdminAppLayout({super.key, required this.child, required this.index});

  @override
  State<AdminAppLayout> createState() => _AdminAppLayoutState();
}

class _AdminAppLayoutState extends State<AdminAppLayout> {
  int _selectedIndex = 0;

  final List<String> _pages = [
    RouterConstant.adminUsers,
    RouterConstant.adminCourses,
    RouterConstant.adminSubjects,
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_pages[index]);
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.index;
    return ResponsiveLayout(
      mobile: _MobileScaffold(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
        child: widget.child,
      ),
      tablet: _TabletScaffold(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
        child: widget.child,
      ),
      web: _DesktopScaffold(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
        child: widget.child,
      ),
    );
  }
}

class _MobileScaffold extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget child;

  const _MobileScaffold({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
  });

  @override
  State<_MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<_MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IGNOUE SOLUTION HUB')),
      drawer: _buildDrawer(context),
      body: widget.child,
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
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IGNOUE SOLUTION HUB',
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
            _buildDrawerItem(context, Icons.group, 'Users', 0),
            _buildDrawerItem(context, Icons.school, 'Courses', 1),
            const Spacer(),
            const ProfileCardWidget(), // Use the new ProfileCardWidget
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    bool isSelected = widget.selectedIndex == index;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return MouseRegion(
          onEnter: (_) => setInnerState(() => isHovered = true),
          onExit: (_) => setInnerState(() => isHovered = false),
          child: Container(
            color: isSelected
                ? Colors.green.shade100
                : isHovered
                ? Colors.grey.shade200
                : Colors.transparent,
            child: ListTile(
              leading: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                widget.onItemSelected(index);
                Navigator.pop(context); // close drawer
              },
            ),
          ),
        );
      },
    );
  }
}

// Tablet Scaffold with fixed sidebar
class _TabletScaffold extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget child;

  const _TabletScaffold({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IGNOUE SOLUTION HUB')),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf9f9f9), Color(0xFFe8f5e9)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'IGNOUE SOLUTION HUB',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Divider(),
          _buildSidebarItem(context, Icons.group, 'Users', 0),
          _buildSidebarItem(context, Icons.school, 'Courses', 1),
          _buildSidebarItem(context, Icons.menu_book, 'Subjects', 2),
          const Spacer(),
          const ProfileCardWidget(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    bool isSelected = selectedIndex == index;
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return MouseRegion(
          onEnter: (_) => setInnerState(() => isHovered = true),
          onExit: (_) => setInnerState(() => isHovered = false),
          child: Container(
            color: isSelected
                ? Colors.green.shade100
                : isHovered
                ? Colors.grey.shade200
                : Colors.transparent,
            child: ListTile(
              leading: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => onItemSelected(index),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopScaffold extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget child;

  const _DesktopScaffold({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
  });

  @override
  State<_DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<_DesktopScaffold> {
  bool _isSidebarCollapsed = false;
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IGNOUE SOLUTION HUB'),
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
          _buildSidebar(context),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: _isSidebarCollapsed ? 70 : 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf9f9f9), Color(0xFFe8f5e9)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isSidebarCollapsed
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
          _buildSidebarItem(Icons.group, 'Users', 0),
          _buildSidebarItem(Icons.school, 'Courses', 1),
          _buildSidebarItem(Icons.menu_book, 'Subjects', 2),
          const Spacer(),
          ProfileCardWidget(isCollapsed: _isSidebarCollapsed),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, int index) {
    bool isSelected = widget.selectedIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : (_hoveredIndex == index
                    ? Theme.of(context).primaryColor.withOpacity(0.08)
                    : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          minLeadingWidth: 24,
          leading: Icon(
            icon,
            size: 22,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (_hoveredIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade700),
          ),
          title: _isSidebarCollapsed
              ? null
              : Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (_hoveredIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade700),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
          onTap: () => widget.onItemSelected(index),
        ),
      ),
    );
  }
}
