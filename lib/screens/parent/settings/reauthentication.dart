import 'package:cheer/themes/theme.dart';
import 'package:cheer/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cheer/models/user.dart';

class Reauthentication extends StatefulWidget {
  const Reauthentication({super.key});
  @override
  State<Reauthentication> createState() => _ReauthenticationState();
}

class _ReauthenticationState extends State<Reauthentication> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _old_passwordController = TextEditingController();
  final TextEditingController _new_passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _old_obscureText = true;
  bool _new_obscureText = true;
  bool _isLoading = false;
  FocusNode _old_focusNode = FocusNode();
  FocusNode _new_focusNode = FocusNode();
  getUser? currentUser;
  String? email;
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
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
            _emailController.text = currentUser!.email!;
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

  Future<void> _logout() async {
    try {
      Navigator.pop(context); // Close the settings page
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メールアドレスを入力してください。';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return '有効なメールアドレスを入力してください。';
    }
    return null;
  }

  String? _old_validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'パスワードを入力してください。';
    }
    if (value.length < 6) {
      return 'パスワードは6文字以上で入力してください。';
    }
    final passwordRegExp = RegExp(
      r'^[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]+$',
    );
    if (!passwordRegExp.hasMatch(value)) {
      return 'パスワードは半角英数字で入力してください。';
    }
    return null;
  }

  String? _new_validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'パスワードを入力してください。';
    }
    if (value.length < 6) {
      return 'パスワードは6文字以上で入力してください。';
    }
    final passwordRegExp = RegExp(
      r'^[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]+$',
    );
    if (!passwordRegExp.hasMatch(value)) {
      return 'パスワードは半角英数字で入力してください。';
    }
    return null;
  }

  Future<void> reauthenticateAndChangePassword(
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;

      if (user == null) {
        print("No user is signed in.");
        return;
      }

      // Use old password here for reauthentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      print("✅ Reauthentication successful");

      // Now update the password to the new one
      await user.updatePassword(newPassword);
      print("✅ Password updated successfully");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("パスワードが正常に更新されました")));
    } on FirebaseAuthException catch (e) {
      print("❌ Failed: ${e.code} - ${e.message}");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("エラー: ${e.message}")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _emailController.dispose();
    _old_passwordController.dispose();
    _new_passwordController.dispose();
    _old_focusNode.dispose();
    _new_focusNode.dispose();
    super.dispose();
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
              'パスワードの変更',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
        actions: [
          Tooltip(
            message: 'Logout',
            child: IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            width: AppTheme.fullWidth(context),
            height: AppTheme.fullHeight(context) * .8,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                TitleText(
                  text: 'パスウード変更',
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
                SizedBox(height: 30),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _userController,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          labelText: 'ユーザー名',
                          hintText: 'ユーザー名',
                          suffixIcon: Icon(Icons.cancel, color: Colors.orange),
                        ),
                        validator: _validateUser,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          labelText: 'メールアドレス',
                          hintText: 'メールアドレス',
                          suffixIcon: Icon(Icons.cancel, color: Colors.orange),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _old_passwordController,
                        focusNode: _old_focusNode,
                        obscureText: _old_obscureText,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          labelText: '古いパスワード',
                          hintText: _old_focusNode.hasFocus
                              ? '古いパスワード(半角英数字６文字以上)'
                              : '古いパスワード',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _old_obscureText
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              setState(() {
                                _old_obscureText = !_old_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: _old_validatePassword,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _new_passwordController,
                        focusNode: _new_focusNode,
                        obscureText: _new_obscureText,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          labelText: '新しいパスワード',
                          hintText: _new_focusNode.hasFocus
                              ? '新しいパスワード(半角英数字６文字以上)'
                              : '新しいパスワード',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _new_obscureText
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              setState(() {
                                _new_obscureText = !_new_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: _new_validatePassword,
                      ),
                      const SizedBox(height: 25),
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.orange)
                          : Customtextbutton(
                              text: '確認',
                              onPressed: () {
                                reauthenticateAndChangePassword(
                                  _emailController.text.trim(),
                                  _old_passwordController.text.trim(),
                                  _new_passwordController.text.trim(),
                                );
                              },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
