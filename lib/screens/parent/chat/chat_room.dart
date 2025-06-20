import 'dart:convert';
import 'package:cheer/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cheer/models/data.dart';
import 'package:cheer/screens/settings.dart';

class ChatRoom extends StatefulWidget {
  final String userEmail;
  final String? friendAvatarUrl;
  const ChatRoom({super.key, required this.userEmail, this.friendAvatarUrl});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  String? currentUserAvatarUrl;
  bool isAvatarLoading = true;
  String? currentUserEmail;
  String? friendAvatarUrl;
  late ScrollController _scrollController;
  List<String> stickers = [];
  bool isStickerPickerVisible = false;
  GlobalKey _stickerButtonKey = GlobalKey();
  String selectedEmoji = '';

  @override
  void initState() {
    super.initState();
    currentUserEmail = _auth.currentUser?.email;
    fetchFriendAvatar();
    fetchCurrentUserAvatar();
    _scrollController = ScrollController();
  }

  // 文字列がBase64でエンコードされた画像であるかどうかを検出する
  bool isBase64Image(String? data) {
    if (data == null) return false;
    if (data.startsWith('data:image')) return true;
    try {
      base64.decode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchFriendAvatar() async {
    final friendEmail = widget.userEmail;
    if (friendEmail.isEmpty) return;

    try {
      final stageSnapshot = await FirebaseFirestore.instance
          .collection('stage')
          .get();
      for (var stageDoc in stageSnapshot.docs) {
        final userQuery = await stageDoc.reference
            .collection('user')
            .where('email', isEqualTo: friendEmail)
            .limit(1)
            .get();
        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          final avatar = userDoc.data()['avatarUrl'] as String?;
          setState(() {
            friendAvatarUrl = avatar;
          });
          return;
        }
      }
    } catch (e) {
      print("Error fetching friend avatar: $e");
    }
  }

  Future<void> fetchCurrentUserAvatar() async {
    if (currentUserEmail == null) return;

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection('stage')
          .doc('cheer')
          .collection('user')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final avatar = userQuery.docs.first.data()['avatarUrl'] as String?;
        setState(() {
          currentUserAvatarUrl = avatar;
          isAvatarLoading = false;
        });
      } else {
        setState(() {
          isAvatarLoading = false;
        });
        print("User with email $currentUserEmail not found.");
      }
    } catch (e) {
      setState(() {
        isAvatarLoading = false;
      });
      print("Error fetching current user's avatarUrl: $e");
    }
  }

  Future<void> sendMessage(String message, {String? emotion}) async {
    if (message.isEmpty && emotion == null) return;

    final timestamp = FieldValue.serverTimestamp();
    final cheerRef = FirebaseFirestore.instance
        .collection('stage')
        .doc('cheer');

    await cheerRef.collection('chat').add({
      'from': currentUserEmail,
      'to': widget.userEmail,
      'message': message,
      'emotion': emotion,
      'timestamp': timestamp,
      'type': emotion != null ? 'emotion' : 'text',
      'read': false,
    });

    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> markMessagesAsRead() async {
    final chatCollection = FirebaseFirestore.instance
        .collection('stage')
        .doc('cheer')
        .collection('chat');

    final unreadMessagesQuery = await chatCollection
        .where('from', isEqualTo: widget.userEmail)
        .where('to', isEqualTo: currentUserEmail)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in unreadMessagesQuery.docs) {
      await doc.reference.update({'read': true});
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return const Stream.empty();
    }
    final currentUserEmail = user.email!;
    final chatCollection = FirebaseFirestore.instance
        .collection('stage')
        .doc('cheer')
        .collection('chat');

    return chatCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final messages = snapshot.docs
              .map((doc) => doc.data())
              .where(
                (msg) =>
                    (msg['from'] == currentUserEmail &&
                        msg['to'] == widget.userEmail) ||
                    (msg['from'] == widget.userEmail &&
                        msg['to'] == currentUserEmail),
              )
              .toList();
          return messages.cast<Map<String, dynamic>>();
        });
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserSettings()),
    );
  }

  Future<void> _logout() async {
    try {
      // await FirebaseAuth.instance.signOut();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _scrollController.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatRoom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userEmail != widget.userEmail) {
      print(
        'Friend changed from ${oldWidget.userEmail} to ${widget.userEmail}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.fullWidth(context);
    final isLargeScreen = screenWidth > 600;
    final avatarSize = isLargeScreen ? 60.0 : 45.0;
    final fontSize = isLargeScreen ? 16.0 : 14.0;
    final messagePadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.05,
      vertical: 2,
    );

    if (isAvatarLoading) {
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox.shrink(),
        actions: [
          Tooltip(
            message: 'Settings',
            child: IconButton(
              onPressed: _openSettings,
              icon: Icon(Icons.settings),
            ),
          ),
          Tooltip(
            message: 'Logout',
            child: IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];
                if (messages.isNotEmpty) {
                  markMessagesAsRead();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message['from'] == currentUserEmail;

                    Widget avatarWidget(String? avatarUrl) {
                      if (avatarUrl == null || avatarUrl.isEmpty) {
                        return CircleAvatar(
                          radius: avatarSize / 2,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade700,
                          ),
                          backgroundColor: Colors.grey.shade300,
                        );
                      }
                      if (isBase64Image(avatarUrl)) {
                        String base64String = avatarUrl;
                        if (base64String.startsWith('data:image')) {
                          base64String = base64String.substring(
                            base64String.indexOf(',') + 1,
                          );
                        }
                        final bytes = base64.decode(base64String);
                        return CircleAvatar(
                          radius: avatarSize / 2,
                          backgroundImage: MemoryImage(bytes),
                          backgroundColor: Colors.grey.shade300,
                        );
                      } else {
                        return CircleAvatar(
                          radius: avatarSize / 2,
                          backgroundImage: NetworkImage(avatarUrl),
                          backgroundColor: Colors.grey.shade300,
                        );
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: isSender
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isSender)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: avatarWidget(friendAvatarUrl),
                            ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? Colors.blueAccent
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  message['type'] == 'text'
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            right: 20,
                                            bottom: 2,
                                          ),
                                          child: Text(
                                            message['message'] ?? '',
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              color: isSender
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                            right: 24,
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            message['emotion'] ?? '',
                                            style: TextStyle(fontSize: 28),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Icon(
                                      message['read'] == true
                                          ? Icons.done_all
                                          : Icons.done,
                                      size: 16,
                                      color: message['read'] == true
                                          ? (isSender
                                                ? Colors.white
                                                : Colors.black)
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isSender)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: avatarWidget(currentUserAvatarUrl),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: messagePadding,
            child: Row(
              children: [
                IconButton(
                  key: _stickerButtonKey,
                  icon: Icon(Icons.insert_emoticon),
                  onPressed: _showEmojiPicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (value) {
                      sendMessage(value);
                    },
                    textInputAction: TextInputAction
                        .send, // optional: changes keyboard action icon
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.builder(
          padding: EdgeInsets.all(10),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: emojis.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _sendEmoji(emojis[index]);
              },
              child: Center(
                child: Text(emojis[index], style: TextStyle(fontSize: 28)),
              ),
            );
          },
        );
      },
    );
  }

  void _sendEmoji(String emoji) {
    sendMessage('', emotion: emoji);
  }
}
