import 'package:cheer/themes/light_color.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:cheer/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:cheer/screens/parent/parentpage.dart';
import 'package:cheer/config/firebase_initializer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cheer/screens/parent/chat/friendlistpage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _obscureText = true;
  FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _firebaseInitialized = false;
  File? _avatarImage;
  // Commit: Added loading state to show indicator during registration
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await FirebaseInitializer.initialize();
      FirebaseAuth.instance.setLanguageCode('ja');
      setState(() {
        _firebaseInitialized = true;
        print('Firebase initialization success!!');
      });
    } catch (e) {
      setState(() {
        _firebaseInitialized = false;
      });
      print('Firebase initialization failed: $e');
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

  void _onRegisterPressed() async {
    if (!_firebaseInitialized) {
      _showMessage('Firebase is not initialized. Please try again later.');
      return;
    }

    setState(() {
      _autoValidateMode = AutovalidateMode.disabled;
      _isLoading = true; // Show loading indicator
    });

    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _userController.text.trim();
      try {
        String? base64Image;
        if (_avatarImage != null) {
          final exists = await _avatarImage!
              .exists(); // ✅ Commit: Check if file exists
          print('✅ Avatar image exists: $exists');
          if (exists) {
            final bytes = await _avatarImage!.readAsBytes();
            base64Image = 'data:image/png;base64,' + base64Encode(bytes);
            print('✅ Avatar image encoded successfully.');
          } else {
            print('❌ Avatar file does not exist.');
          }
        } else {
          print('⚠️ No avatar image selected.');
        }

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = userCredential.user?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('stage')
              .doc('cheer')
              .collection('user')
              .doc(uid)
              .set({
                'username': username,
                'email': email,
                'avatarUrl': base64Image ?? '',
                'createdAt': FieldValue.serverTimestamp(),
                'isOnline': true,
                'lastSignIn': FieldValue.serverTimestamp(),
              });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _formKey.currentState?.reset();
          _emailController.clear();
          _passwordController.clear();
          setState(() {
            _avatarImage = null;
          });
        });

        setState(() {
          _isLoading = false; // Hide loading indicator
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                FriendListScreen(email: userCredential.user?.email),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = '登録に失敗しました。';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'このメールアドレスは既に使用されています。';
        } else if (e.code == 'weak-password') {
          errorMessage = 'パスワードが弱すぎます。';
        } else if (e.code == 'invalid-email') {
          errorMessage = '無効なメールアドレスです。';
        }
        _showMessage(errorMessage);
        print('FirebaseAuthException: $e');
        setState(() {
          _isLoading = false; // Hide loading on error
        });
      } catch (e) {
        _showMessage('エラーが発生しました。もう一度お試しください。');
        print('Exception: $e');
        setState(() {
          _isLoading = false; // Hide loading on error
        });
      }
    } else {
      // Form not valid
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null && pickedFile.path.isNotEmpty) {
        print('✅ Picked image path: ${pickedFile.path}');
        setState(() {
          _avatarImage = File(pickedFile.path);
        });
      } else {
        print('⚠️ No image selected.');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final spacingLarge = height * 0.05;
    final spacingMedium = height * 0.02;
    final spacingSmall = height * 0.01;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: LightColor.background,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: spacingLarge),
                  TitleText(
                    text: 'Cheermee_test',
                    fontSize: 30,
                    textAlign: TextAlign.center,
                    color: LightColor.orange,
                  ),
                  TitleText(
                    text: '最新登録',
                    fontSize: 20,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: spacingSmall),

                  Stack(
                    children: [
                      Container(
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage: _avatarImage != null
                              ? FileImage(_avatarImage!)
                              : null,
                          child: _avatarImage == null
                              ? Icon(Icons.person, size: 100)
                              : null,
                        ),
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
                            child: Center(
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
                  SizedBox(height: 10),
                  Container(
                    width: width * 0.85,
                    child: TextFormField(
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
                  ),
                  Container(
                    width: width * 0.85,
                    child: TextFormField(
                      controller: _userController,
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
                        labelText: 'ユーザー名',
                        hintText: 'ユーザー名',
                        suffixIcon: Icon(Icons.cancel, color: Colors.orange),
                      ),
                      validator: _validateUser,
                    ),
                  ),
                  SizedBox(height: spacingMedium),
                  Container(
                    width: width * 0.85,
                    child: TextFormField(
                      controller: _passwordController,
                      focusNode: _focusNode,
                      obscureText: _obscureText,
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
                        labelText: 'パスワード',
                        hintText: _focusNode.hasFocus
                            ? 'パスワード(半角英数字６文字以上)'
                            : 'パスワード',
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
                  ),
                  SizedBox(height: spacingSmall),
                  TitleText(text: 'この先の登録画面に進むと同時に私は', color: Colors.black),
                  TitleText(text: '利用規約とプライバシーポリシーに同意します', color: Colors.black),
                  SizedBox(height: spacingMedium),

                  // Commit: Show loading indicator while registering, else show buttons
                  _isLoading
                      ? Column(
                          children: [
                            CircularProgressIndicator(color: Colors.orange),
                            SizedBox(height: 10),
                            TitleText(text: '登録中...', color: Colors.black),
                          ],
                        )
                      : Column(
                          children: [
                            Customtextbutton(
                              text: '最新登録',
                              onPressed: _onRegisterPressed,
                              backgroundcolor: Colors.orange[400]!,
                              bordercolor: Colors.orange,
                              color: Colors.white,
                            ),
                            SizedBox(height: spacingSmall),
                            Customtextbutton(
                              text: '戻る',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Parentpage(),
                                  ),
                                );
                              },
                              backgroundcolor: Colors.white,
                              bordercolor: Colors.orange,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
