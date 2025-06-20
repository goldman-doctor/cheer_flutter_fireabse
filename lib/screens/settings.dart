import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:cheer/screens/parent/settings/profileedit.dart';
import 'package:cheer/screens/parent/settings/reauthentication.dart';
import 'package:cheer/screens/parent/settings/changeemail.dart';
import 'package:cheer/screens/parent/settings/contactUspage.dart';
import 'package:cheer/screens/parent/settings/teamofservice.dart';
import 'package:cheer/screens/parent/settings/privacypolicy.dart';
import 'package:cheer/screens/parent/settings/companyoverview.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});
  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  bool isGoogleUser = false;
  @override
  void initState() {
    super.initState();
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      firebaseUser.providerData.forEach((provider) {
        if (provider.providerId == 'google.com') {
          setState(() {
            isGoogleUser = true;
          });
        }
      });
    }
  }

  Future<void> _logout() async {
    try {
      Navigator.pop(context); // Close the settings page
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leadingWidth: 30,
        leading: SizedBox.shrink(),
        centerTitle: true,
        title: Text('設定', style: TextStyle(fontSize: 18, color: Colors.white)),
        actions: [
          Tooltip(
            message: 'Logout',
            child: IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: ListView(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Profileedit(),
                          ),
                        );
                      },
                      child: Text(
                        'プロフィール編集',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Divider(height: 1),
                    TextButton(
                      child: Text(
                        '子どもアカウント一覧',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.start,
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('開発中です。')));
                      },
                    ),
                    Divider(height: 1),
                    TextButton(
                      child: Text(
                        'パスワードの変更',
                        style: TextStyle(
                          color: isGoogleUser ? Colors.grey : Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: isGoogleUser
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Reauthentication(),
                                ),
                              );
                            },
                    ),
                    Divider(height: 1),
                    TextButton(
                      child: Text(
                        'メールアドレスの変更',
                        style: TextStyle(
                          color: isGoogleUser ? Colors.grey : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: isGoogleUser
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeEmailScreen(),
                                ),
                              );
                            },
                    ),
                    Divider(height: 1),
                    TextButton(
                      child: Text(
                        'お問い合わせ',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactUsPage(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1),
                    TextButton(
                      child: Text(
                        '利用規約',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsOfServicePage(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1),
                    TextButton(
                      child: Text(
                        'プライバシーポシー',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1),
                    TextButton(
                      child: Text(
                        '運営会社',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompanyOverviewScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1),
                    SizedBox(height: 20),
                    Customtextbutton(
                      onPressed: _logout,
                      text: 'ログアウト',
                      bordercolor: Colors.orange,
                      backgroundcolor: Colors.white,
                      color: Colors.orange,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            /// Optional logout button at the bottom
          ],
        ),
      ),
    );
  }
}
