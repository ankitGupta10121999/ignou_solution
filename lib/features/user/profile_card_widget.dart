import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ignousolutionhub/features/user/profile_page.dart';

import '../../constants/firebase_collections.dart';

class ProfileCardWidget extends StatefulWidget {
  final bool isCollapsed;

  const ProfileCardWidget({super.key, this.isCollapsed = false});

  @override
  State<ProfileCardWidget> createState() => _ProfileCardWidgetState();
}

class _ProfileCardWidgetState extends State<ProfileCardWidget> {
  User? _user;
  Map<String, dynamic>? _firestoreUserData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchFirestoreUserData();
  }

  Future<void> _fetchFirestoreUserData() async {
    if (_user != null) {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(_user!.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _firestoreUserData = doc.data();
        });
      }
    }
  }

  String _getInitials(String? displayName, String? email) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').map((s) => s[0]).join().toUpperCase();
    } else if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const SizedBox.shrink();
    }

    final String? displayName =
        _user!.displayName ?? _firestoreUserData?['name'];
    final String? email = _user!.email;
    final String? photoURL = _user!.photoURL ?? _firestoreUserData?['photoURL'];

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => ProfilePage()));
        },
        child: Padding(
          padding: EdgeInsets.all(widget.isCollapsed ? 4.0 : 12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL)
                    : null,
                child: photoURL == null
                    ? Text(
                        _getInitials(displayName, email),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              !widget.isCollapsed ? SizedBox(width: 16) : Container(),
              !widget.isCollapsed ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName ?? 'No Name',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email ?? 'No Email',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
