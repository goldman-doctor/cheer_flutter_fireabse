import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cheer/widgets/customtextbutton.dart';

class ContactUsPage extends StatefulWidget {
  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final Uri _emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'support@cheermee.com',
    queryParameters: {'subject': 'Inquiry about Cheermee'},
  );

  final String _websiteUrl = 'https://cheermee.com/';
  final String _instagramUrl = 'https://instagram.com/cheermee.jp';
  final String _twitterUrl = 'https://twitter.com/cheermee_jp';

  // Helper function to launch URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchEmail() async {
    if (!await launchUrl(_emailLaunchUri)) {
      throw 'Could not launch email app';
    }
  }

  Future<void> _logout() async {
    try {
      Navigator.pop(context);
    } catch (e) {
      print('Error logging out: $e');
    }
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
              'お問い合わせ',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('ご質問やサポートが必要な場合は、お問い合わせください:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),

            ElevatedButton.icon(
              icon: Icon(Icons.email),
              label: Text('Send Email'),
              onPressed: _launchEmail,
            ),
            SizedBox(height: 15),

            ElevatedButton.icon(
              icon: Icon(Icons.language),
              label: Text('Visit Official Website'),
              onPressed: () => _launchUrl(_websiteUrl),
            ),
            SizedBox(height: 15),

            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Instagram'),
              onPressed: () => _launchUrl(_instagramUrl),
            ),
            SizedBox(height: 15),

            ElevatedButton.icon(
              icon: Icon(Icons.alternate_email),
              label: Text('Twitter'),
              onPressed: () => _launchUrl(_twitterUrl),
            ),
            SizedBox(height: 30),
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
