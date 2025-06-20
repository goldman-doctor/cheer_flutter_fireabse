import 'package:cheer/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cheer/widgets/usercard.dart';
import 'package:cheer/screens/parent/chat/chat_room.dart';
import 'package:cheer/widgets/setstatus.dart';

class FriendListScreen extends StatefulWidget {
  final String? email;
  const FriendListScreen({super.key, required this.email});
  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userStatusService = UserStatusService();
  bool _isLoggingOut = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });
    if (_auth.currentUser != null) {
      await userStatusService.setUserOffline(_auth.currentUser!.uid);
    }
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } catch (e) {
      print('Error logging out: $e');
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getAllUsersExceptCurrent() {
    final currentUserEmail = _auth.currentUser!.email;
    return FirebaseFirestore.instance.collection('stage').snapshots().asyncMap((
      stageSnapshot,
    ) async {
      final allUsers = <Map<String, dynamic>>[];

      for (var cheerDoc in stageSnapshot.docs) {
        final userSnapshot = await cheerDoc.reference.collection('user').get();

        for (var userDoc in userSnapshot.docs) {
          allUsers.add(userDoc.data() as Map<String, dynamic>);
        }
      }
      allUsers.removeWhere((user) => user['email'] == currentUserEmail);

      // Deduplicate users by email
      final uniqueUsers = <String, Map<String, dynamic>>{};
      for (var user in allUsers) {
        uniqueUsers[user['email']] = user;
      }

      return uniqueUsers.values.toList();
    });
  }

  Stream<int> getUnreadMessageCount(String friendEmail) {
    final currentUserEmail = _auth.currentUser!.email!;
    return FirebaseFirestore.instance
        .collection('stage')
        .doc('cheer')
        .collection('chat')
        .where('from', isEqualTo: friendEmail)
        .where('to', isEqualTo: currentUserEmail)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.fullWidth(context);
    final screenHeight = AppTheme.fullHeight(context);
    final isLargeScreen = screenWidth > 600;
    final avatarSize = isLargeScreen ? 60.0 : 45.0;
    final fontSize = isLargeScreen ? 40.0 : 30.0;
    final listPadding = EdgeInsets.symmetric(horizontal: screenWidth * 0.05);

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        actions: [
          Tooltip(
            message: 'Logout',
            child: IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getAllUsersExceptCurrent(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No users found"));
                }
                final usersList = snapshot.data!;

                return ListView.builder(
                  itemCount: usersList.length,
                  padding: listPadding,
                  itemBuilder: (context, index) {
                    final user = usersList[index];
                    final avatarUrl = user['avatarUrl'];
                    final hasAvatarUrl =
                        avatarUrl != null && avatarUrl.isNotEmpty;
                    final avatarText = user['email']?.isNotEmpty ?? false
                        ? user['email'][0].toUpperCase()
                        : 'N/A';

                    return StreamBuilder<int>(
                      stream: getUnreadMessageCount(user['email']),
                      builder: (context, unreadSnapshot) {
                        int unreadCount = 0;
                        if (unreadSnapshot.hasData) {
                          unreadCount = unreadSnapshot.data!;
                        }
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: Usercard(
                            username: user['username'] ?? 'No userName',
                            email: user['email'] ?? 'No email',
                            avatarBackgroundColor: Colors.grey,
                            avatarText: hasAvatarUrl ? '' : avatarText,
                            avatarUrl: hasAvatarUrl ? avatarUrl : null,
                            avatarSize: avatarSize,
                            fontSize: fontSize,
                            isOnline: user['isOnline'] ?? false,
                            unreadCount: unreadCount,
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => ChatRoom(
                                    userEmail: usersList[index]['email'],
                                    friendAvatarUrl:
                                        usersList[index]['avatarUrl'],
                                  ),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          //ログアウト時に読み込みオーバーレイを表示する
          if (_isLoggingOut)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
