import 'package:flutter/material.dart';
import 'package:cheer/themes/theme.dart';
import 'package:cheer/themes/light_color.dart';
import 'package:cheer/widgets/title_text.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:cheer/screens/mainpage.dart';
import 'package:cheer/screens/parent/register.dart';
import 'package:cheer/screens/parent/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cheer/screens/parent/chat/friendlistpage.dart';
import 'package:cheer/config/firebase_initializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Parentpage extends StatefulWidget {
  const Parentpage({super.key});

  @override
  State<Parentpage> createState() => _ParentPageState();
}

class _ParentPageState extends State<Parentpage> {
  bool _firebaseInitialized = false;
  bool isLoading = false;
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.signOut();
      // ステップ1: Googleでサインイン
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        return null;
      }
      // ステップ2: Google Authを使用して新しい認証情報を作成する
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // ステップ3: Google認証情報を使用してFirebaseにログインする
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      final userId = user!.uid;
      if (user != null) {
        final userDocRef = FirebaseFirestore.instance
            .collection('stage')
            .doc('cheer')
            .collection('user')
            .doc(userId);

        // ステップ4: ユーザードキュメントが存在するかどうかを確認する
        final docSnapshot = await userDocRef.get();
        if (!docSnapshot.exists) {
          // If user document doesn't exist, create a new one
          final email = user.email;
          final displayName = user.displayName;
          try {
            await userDocRef.set({
              'email': email,
              'username': displayName,
              'avatarUrl': user.photoURL,
              'lastSignIn': FieldValue.serverTimestamp(),
              'createdAt': FieldValue.serverTimestamp(),
              'isOnline': true,
            }, SetOptions(merge: true));
            print("User document created successfully");
          } catch (e) {
            print("Error creating Firestore user document: $e");
          }
        } else {
          await userDocRef.update({
            'lastSignIn': FieldValue.serverTimestamp(),
            'isOnline': true,
          });
          print("User document updated with lastSignIn and status");
        }
      }
      // ステップ5: userCredentialを返す
      return userCredential;
    } on PlatformException catch (e) {
      if (e.code == GoogleSignIn.kNetworkError) {
        String errorMessage =
            "A network error (such as timeout, interrupted connection or unreachable host) has occurred.";
        print(errorMessage);
      } else {
        String errorMessage = "Something went wrong.";
        print(errorMessage);
      }
    }
  }

  Future<void> handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userCredential = await signInWithGoogle();

      if (userCredential != null) {
        // 次の画面に移動する
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FriendListScreen(email: userCredential.user!.email),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Googleサインインがキャンセルされました。')));
      }
    } catch (e) {
      print('Sign-in error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Googleサインイン中にエラーが発生しました。')));
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final width = AppTheme.fullWidth(context);
    final height = AppTheme.fullHeight(context);

    // Define relative vertical spacing
    final spacingLarge = height * 0.05; // 5%
    final spacingMedium = height * 0.025; // 2.5%
    final spacingSmall = height * 0.01; // 1%

    final imageWidth = width / 3;
    final imageHeight = height / 5;

    return Stack(
      alignment: Alignment.center,
      children: [
        SafeArea(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: LightColor.background),
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: spacingLarge),
                TitleText(
                  text: 'Cheermee',
                  fontSize: 30,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacingSmall),
                TitleText(
                  text: 'Cheermmeeへようこそ！',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: spacingMedium),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TitleText(
                      text: 'Cheermeeは、スタンプだけのコキュこケーションで',
                      fontSize: 16,
                      color: Colors.black87,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacingSmall),
                    TitleText(
                      text: '子どものやる気を引き出すアプリです',
                      fontSize: 16,
                      color: Colors.black87,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: spacingMedium),

                // Image with constrained size relative to screen
                SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Image.asset('assets/loading.png', fit: BoxFit.contain),
                ),
                SizedBox(height: spacingSmall),

                SizedBox(
                  width: width * 0.6,
                  child: Customtextbutton(
                    text: '最新登録',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: spacingMedium),

                TitleText(
                  text: 'すでに利用したことがある方はここち',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: spacingSmall),

                SizedBox(
                  width: width * 0.6,
                  child: Customtextbutton(
                    text: 'ログイン',
                    bordercolor: Colors.amber,
                    backgroundcolor: Colors.white,
                    color: Colors.orange,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                  ),
                ),
                SizedBox(height: spacingSmall),

                SizedBox(
                  width: width * 0.6,
                  child: Customtextbutton(
                    text: 'Google',
                    bordercolor: LightColor.lightblack,
                    backgroundcolor: Colors.white,
                    color: Colors.black,
                    leading: Image.asset(
                      'assets/google.png',
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () => handleGoogleSignIn(),
                  ),
                ),

                SizedBox(height: spacingSmall),

                SizedBox(
                  width: width * 0.6,
                  child: Customtextbutton(
                    text: '戻る',
                    bordercolor: Colors.amber,
                    backgroundcolor: Colors.white,
                    color: Colors.orange,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: spacingSmall * 1.5),
                  TitleText(
                    text: "ログイン中...",
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
