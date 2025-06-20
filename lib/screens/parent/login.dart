import 'package:cheer/themes/light_color.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:flutter/material.dart';
import 'package:cheer/screens/parent/parentpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cheer/screens/parent/chat/friendlistpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cheer/widgets/setstatus.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String? _userId;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userStatusService = UserStatusService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_userId == null) return;

    if (state == AppLifecycleState.paused) {
      print('Setting user offline...');
      await userStatusService.setUserOffline(_userId!);
    } else if (state == AppLifecycleState.resumed) {
      print('Setting user online...');
      await userStatusService.setUserOnline(_userId!);
    }
  }

  Future<void> _logout() async {
    if (_userId != null) {
      await userStatusService.setUserOffline(_userId!);
    }
    await FirebaseAuth.instance.signOut();

    // Navigate back to Parentpage or Login page as needed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Parentpage()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      _userId = userCredential.user?.uid;

      if (_userId != null) {
        await userStatusService.setUserOnline(_userId!);
      } else {
        print('User not signed in');
      }
      // Login success!
      _showMessage('ログインに成功しました。');
      _emailController.clear();
      _passwordController.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FriendListScreen(email: userCredential.user?.email),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'ログインに失敗しました。';
      if (e.code == 'user-not-found') {
        errorMessage = 'ユーザーが見つかりません。';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'メールアドレスまたはパスワードが正しくありません。もう一度確認してください。';
        _passwordController.clear();
      } else if (e.code == 'invalid-email') {
        errorMessage = '無効なメールアドレスです。';
      }
      _showMessage(errorMessage);
      print('FirebaseAuthException: $e');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('エラーが発生しました。もう一度お試しください。');
      print('Exception: $e');
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'パスワードを入力してください。';
    }
    if (value.length < 6) {
      return 'パスワードは6文字以上で入力してください。';
    }
    final passwordRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    if (!passwordRegExp.hasMatch(value)) {
      return 'パスワードは半角英数字で入力してください。';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メールアドレスを入力してください。';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return '無効なメールアドレスです。';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;
    final verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey, // << Added form key
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: verticalSpacing * 5),

                    Text(
                      'ログイン',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: verticalSpacing * 2),

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
                        suffixIcon: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.orange),
                          onPressed: () {
                            _emailController.clear();
                            setState(() {});
                          },
                        ),
                      ),
                      validator: _validateEmail,
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: verticalSpacing),

                    TextFormField(
                      controller: _passwordController,
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
                        hintText: 'パスワード',
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                    ),

                    SizedBox(height: verticalSpacing),
                    _isLoading
                        ? Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text(
                                'ログイン中...',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    105,
                                    105,
                                    105,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Customtextbutton(
                            text: '確認',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                            backgroundcolor: LightColor.orange,
                            bordercolor: LightColor.orange,
                            color: Colors.white,
                          ),

                    SizedBox(height: verticalSpacing * 2),

                    Customtextbutton(
                      text: '戻る',
                      onPressed: () {
                        _logout(); // Call logout here to update isOnline false, or just navigate if you want
                        // Or if you want simple navigation without logout:
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => Parentpage()),
                        // );
                      },
                      backgroundcolor: LightColor.lightGrey,
                      bordercolor: LightColor.orange,
                      color: LightColor.orange,
                    ),

                    SizedBox(height: verticalSpacing * 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
