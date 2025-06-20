import 'dart:async';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeEmailScreen extends StatefulWidget {
  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _emailController = TextEditingController();
  final _confirmemailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FocusNode _focusNode = FocusNode();
  bool _obscureText = true;

  bool _isSendingVerification = false;
  bool _isEmailVerified = false;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();

    _timer = Timer.periodic(Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _confirmemailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    User? user = _auth.currentUser;

    await user?.reload();
    user = _auth.currentUser;
    setState(() {
      _isEmailVerified = user?.emailVerified ?? false;
    });
    if (_isEmailVerified) {
      _timer?.cancel();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email successfully verified!')));
    }
  }

  Future<void> _changeEmail() async {
    final newEmail = _emailController.text.trim();
    final confirmEmail = _confirmemailController.text.trim();
    final currentPassword = _passwordController.text.trim();

    if (newEmail.isEmpty || confirmEmail.isEmpty || currentPassword.isEmpty) {
      setState(() {
        _errorMessage = '新しいメールアドレスと現在のパスワードを入力してください。';
      });
      return;
    }

    if (newEmail != confirmEmail) {
      setState(() {
        _errorMessage = 'メールアドレスが一致しません。';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = null;
        _isSendingVerification = true;
      });

      User? user = _auth.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = 'ユーザーがログインしていません。';
          _isSendingVerification = false;
        });
        return;
      }

      // ✅ Check if current email is verified
      await user.reload(); // Refresh user info
      // if (!user.emailVerified) {
      //   setState(() {
      //     _errorMessage = '現在のメールアドレスが未確認です。まずメール確認を行ってください。';
      //     _isSendingVerification = false;
      //   });
      //   return;
      // }

      // Step 1: Reauthenticate the user with current email and password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Step 2: Update the email address
      await user.verifyBeforeUpdateEmail(newEmail);
      await user.reload();
      user = _auth.currentUser;

      // Step 3: Update Firestore email field
      // final firestore = FirebaseFirestore.instance;
      // final userDocRef = firestore
      //     .collection('stage')
      //     .doc('cheer')
      //     .collection('user')
      //     .doc(user!.uid);

      // await userDocRef.update({'email': newEmail});

      // Step 4: Send verification email to the new address
      // await user.sendEmailVerification();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('確認メールを $newEmail に送信しました。')));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'パスワードが違います。';
          break;
        case 'requires-recent-login':
          message = 'セキュリティのため、再ログインしてください。';
          break;
        case 'email-already-in-use':
          message = 'このメールアドレスは既に使用されています。';
          break;
        case 'operation-not-allowed':
          message = '操作が許可されていません。Firebaseの認証設定を確認してください。';
          break;
        default:
          message = 'Firebase 認証エラー: ${e.message ?? '不明なエラー'}';
      }
      setState(() {
        _errorMessage = message;
      });
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Firestore の更新に失敗しました: ${e.message ?? '不明なエラー'}';
      });
    } finally {
      setState(() {
        _isSendingVerification = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() {
        _isSendingVerification = true;
      });
      User? user = _auth.currentUser;
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification email resent')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not resend verification email')),
      );
    } finally {
      setState(() {
        _isSendingVerification = false;
      });
    }
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

  String? _confirmvalidateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メールアドレスを入力してください。';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return '有効なメールアドレスを入力してください。';
    }
    return null;
  }

  Future<void> _logout() async {
    try {
      Navigator.pop(context); // Close the settings page
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  String? _validatePassword(String? value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leadingWidth: 180,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'メールアドレスの変更',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 40),
            TextFormField(
              controller: _passwordController,
              focusNode: _focusNode,
              obscureText: _obscureText,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                labelText: 'パスワード',
                hintText: _focusNode.hasFocus ? 'パスワード(半角英数字６文字以上)' : 'パスワード',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              validator: _validatePassword,
            ),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                labelText: '新しいメールアドレス',
                hintText: '新しいメールアドレス',
                suffixIcon: Icon(Icons.cancel, color: Colors.orange),
              ),
              validator: _validateEmail,
            ),
            TextFormField(
              controller: _confirmemailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
                labelText: '確認するメールアドレス',
                hintText: '確認するメールアドレス',
                suffixIcon: Icon(Icons.cancel, color: Colors.orange),
              ),
              validator: _confirmvalidateEmail,
            ),
            SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            Customtextbutton(
              bordercolor: Colors.orange,
              backgroundcolor: Colors.orange,
              color: Colors.white,
              onPressed: _isSendingVerification ? null : _changeEmail,
              text: _isSendingVerification ? '送信中...' : 'メールアドレスの変更',
            ),
            SizedBox(height: 20),
            if (!_isEmailVerified)
              Column(
                children: [
                  Text('メールアドレスは確認されていません。受信トレイをご確認ください。'),
                  Customtextbutton(
                    bordercolor: Colors.orange,
                    backgroundcolor: Colors.orange,
                    color: Colors.white,
                    onPressed: _isSendingVerification
                        ? null
                        : _resendVerificationEmail,
                    text: '確認メールを再送信',
                  ),
                ],
              ),
            if (_isEmailVerified)
              Text('あなたのメールは確認されました!', style: TextStyle(color: Colors.green)),

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
