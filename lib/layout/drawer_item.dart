import 'package:flutter/material.dart';

class DrawerItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String path;
  final String currentPath;
  final Function(String) onNavigate;
  final bool isCollapsed;
  final bool isSelected;

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.path,
    required this.currentPath,
    required this.onNavigate,
    this.isCollapsed = false,
    this.isSelected = false,
    super.key,
  });

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : isHovered
              ? Theme.of(context).primaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(
            widget.icon,
            size: 22,
            color: widget.isSelected || isHovered
                ? Theme.of(context).primaryColor
                : Colors.grey.shade700,
          ),
          title: widget.isCollapsed
              ? null
              : Text(
            widget.title,
            style: TextStyle(
              color: widget.isSelected || isHovered
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade700,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          onTap: () => widget.onNavigate(widget.path),
        ),
      ),
    );
  }
}
