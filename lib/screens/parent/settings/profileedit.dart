import 'package:cheer/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cheer/models/user.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Profileedit extends StatefulWidget {
  const Profileedit({super.key});
  @override
  State<Profileedit> createState() => _ProfileeditState();
}

class _ProfileeditState extends State<Profileedit> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  getUser? currentUser;
  String? email;
  File? _avatarImage;
  bool _isLoading = false;
  final TextEditingController _userController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    ); // or ImageSource.camera

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> fetchUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('stage')
            .doc('cheer')
            .collection('user')
            .where('email', isEqualTo: firebaseUser.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data();
          setState(() {
            currentUser = getUser.fromJson(data);
            email = currentUser?.email;
            _userController.text = currentUser?.username ?? '';
          });
        } else {
          print("No user found with email: ${firebaseUser.email}");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  ImageProvider? _buildAvatarImage() {
    if (_avatarImage != null) {
      // Show picked image if available
      return FileImage(_avatarImage!);
    }

    final avatarUrl = currentUser?.avatarUrl;
    if (avatarUrl == null) return null;

    if (avatarUrl.startsWith('data:image')) {
      final base64Str = avatarUrl.split(',').last;
      final decodedBytes = base64Decode(base64Str);
      return MemoryImage(decodedBytes);
    }

    final base64Pattern = RegExp(r'^[A-Za-z0-9+/=]+$');
    if (avatarUrl.length > 100 && base64Pattern.hasMatch(avatarUrl)) {
      try {
        final decodedBytes = base64Decode(avatarUrl);
        return MemoryImage(decodedBytes);
      } catch (e) {
        print('Failed to decode base64 avatar: $e');
        return null;
      }
    }

    return NetworkImage(avatarUrl);
  }

  Future<void> _logout() async {
    try {
      Navigator.pop(context);
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  String? _validateUser(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ユーザー名を入力してください。';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      print("No logged-in user.");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登録に失敗しました。')));
      return;
    }

    String? avatarBase64;
    if (_avatarImage != null) {
      final bytes = await _avatarImage!.readAsBytes();
      avatarBase64 = 'data:image/png;base64,' + base64Encode(bytes);
    } else {
      avatarBase64 = currentUser?.avatarUrl;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('stage')
          .doc('cheer')
          .collection('user')
          .where('email', isEqualTo: firebaseUser.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('stage')
            .doc('cheer')
            .collection('user')
            .doc(docId)
            .update({
              'username': _userController.text.trim(),
              'avatarUrl': avatarBase64,
            });

        setState(() {
          currentUser = getUser(
            email: firebaseUser.email,
            username: _userController.text.trim(),
            avatarUrl: avatarBase64,
          );
          _avatarImage = null;
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登録に成功しました！')));
      } else {
        print("User document not found to update.");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登録に失敗しました。')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登録に失敗しました。')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leadingWidth: 150,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'プロフィール編集',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: _buildAvatarImage(),
                    backgroundColor: Colors.grey[300],
                  ),
                  Positioned(
                    bottom: 5,
                    right: MediaQuery.of(context).size.width / 2 - 100 - 15,
                    child: GestureDetector(
                      onTap: () async {
                        await _pickImage();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: AppTheme.fullWidth(context) * 0.85,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                    labelText: 'ユーザー名',
                    hintText: 'ユーザー名',
                    suffixIcon: Icon(Icons.cancel, color: Colors.orange),
                  ),
                  validator: _validateUser,
                ),
              ),
            ),

            const SizedBox(height: 15),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.orange)
                : Customtextbutton(
                    text: '確認',
                    onPressed: _saveProfile,
                    bordercolor: Colors.orange,
                    backgroundcolor: Colors.orange,
                    color: Colors.white,
                  ),
            const SizedBox(height: 15),
            Customtextbutton(
              text: '戻る',
              onPressed: _logout,
              bordercolor: Colors.orange,
              backgroundcolor: Colors.orange,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
