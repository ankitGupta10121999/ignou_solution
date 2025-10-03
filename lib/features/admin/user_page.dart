import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ignousolutionhub/constants/role_constants.dart';
import 'package:ignousolutionhub/models/user_model.dart';
import 'package:ignousolutionhub/utils/commmon_utils.dart';
import '../../core/firestore_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirestoreService _firestoreService = FirestoreService();

  // ----------------- ADD USER DIALOG -----------------
  void _addUserDialog() {
    String name = "";
    String email = "";
    String phone = "";
    String role = RoleConstants.student;
    String password = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add User"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Name", (v) => name = v),
              _buildTextField("Email", (v) => email = v),
              _buildTextField("Phone Number", (v) => phone = v),
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: DropdownButtonFormField<String>(
                  initialValue: role,
                  items: [RoleConstants.admin, RoleConstants.student]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => role = v!,
                  decoration: const InputDecoration(labelText: "Role"),
                ),
              ),
              _buildTextField("Password", (v) => password = v, isPassword: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _firestoreService.addUser(UserModel(
                  uid: CommonUtils.generateUuid(),
                  email: email,
                  role: role,
                  name: name,
                  phone: phone,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ----------------- EDIT USER DIALOG -----------------
  void _editUserDialog(Map<String, dynamic> user) {
    String name = user["name"];
    String email = user["email"];
    String phone = user["phone"];
    String role = user["role"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update User"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Name", (v) => name = v, initial: name),
              _buildTextField("Email", (v) => email = v, initial: email),
              _buildTextField("Phone Number", (v) => phone = v, initial: phone),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: [RoleConstants.admin, RoleConstants.student]
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: "Role"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user["name"] = name;
                user["email"] = email;
                user["phone"] = phone;
                user["role"] = role;
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String id) {
    // TODO: hook firestore delete
  }

  // ----------------- HELPER: TEXT FIELD -----------------
  Widget _buildTextField(String label, Function(String) onChanged,
      {String? initial, bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: initial != null ? TextEditingController(text: initial) : null,
        decoration: InputDecoration(labelText: label),
        obscureText: isPassword,
        onChanged: onChanged,
      ),
    );
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addUserDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add User"),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _firestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No users found. Click "+" to add one.'),
            );
          }

          final users = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                // ----------- Web/Tablet → DataTable -----------
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // padding: EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 24.w,
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                      columns: const [
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Phone")),
                        DataColumn(label: Text("Role")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: users.map((u) {
                        return DataRow(cells: [
                          DataCell(Text(u.name ?? "-")),
                          DataCell(Text(u.email)),
                          DataCell(Text(u.phone ?? "-")),
                          DataCell(Text(u.role)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editUserDialog(u.toMap())),
                              IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteUser(u.uid)),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              } else {
                // ----------- Mobile → List Cards -----------
                return ListView.builder(
                  padding: EdgeInsets.all(8.w),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 26.r,
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            (u.name?.isNotEmpty ?? false) ? u.name![0].toUpperCase() : "?",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                        ),
                        title: Text(u.name ?? "-", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.email, size: 16, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Expanded(child: Text(u.email ?? "-", style: TextStyle(fontSize: 14.sp))),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                SizedBox(width: 4.w),
                                Text(u.phone ?? "-", style: TextStyle(fontSize: 14.sp)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  u.role == RoleConstants.admin ? Icons.admin_panel_settings : Icons.school,
                                  size: 16,
                                  color: Colors.teal,
                                ),
                                SizedBox(width: 4.w),
                                Text(u.role ?? "-", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        trailing: Wrap(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editUserDialog(u.toMap())),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(u.uid)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
