import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cheer/models/snsinfo.dart';

class CompanyOverviewScreen extends StatefulWidget {
  CompanyOverviewScreen({Key? key}) : super(key: key);
  @override
  State<CompanyOverviewScreen> createState() => _CompanyOverviewScreenState();
}

class _CompanyOverviewScreenState extends State<CompanyOverviewScreen> {
  final String companyName = '株式会社スタート・イノベーション';
  final String ceo = '池田 慈生（いけだ よしお）';
  final String founded = '2014年12月';
  final String address = '東京都渋谷区松濤2-3-6 江川ストリート';
  final String corporateSite = 'https://startinnovation.jp/';
  final String cheermeeSite = 'https://cheermee.com/';

  final List<SnsInfo> snsList = [
    SnsInfo(
      'Instagram',
      '@cheermee_kids',
      'https://www.instagram.com/cheermee_kids/',
    ),
    SnsInfo('note', 'https://note.com/cheermee', 'https://note.com/cheermee'),
    SnsInfo(
      'X（旧Twitter）',
      '@Cheermee_kids',
      'https://twitter.com/Cheermee_kids',
    ),
    SnsInfo(
      'Facebook',
      'Cheermee.for.kids',
      'https://www.facebook.com/Cheermee.for.kids',
    ),
  ];
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
        leadingWidth: 180,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              '📌 会社概要',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('会社名', companyName),
              _buildInfoRow('代表取締役', ceo),
              _buildInfoRow('設立', founded),
              _buildInfoRow('本社所在地', address),
              _buildLinkRow('コーポレートサイト', corporateSite),
              const SizedBox(height: 24),
              const Text(
                '同社は、教育事業や新規事業開発、スタートアップ支援などを手掛けており、'
                'Cheermeeを通じて子どもたちとそのご家族を応援しています。',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Text(
                '📱 Cheermee公式サイト・SNS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildLinkRow('公式サイト', cheermeeSite),
              const SizedBox(height: 12),
              ...snsList.map((sns) => _buildSnsRow(sns)).toList(),
              const SizedBox(height: 24),
              const Text(
                'これらのSNSでは、Cheermeeの最新情報や子育てに役立つコンテンツが発信されています。',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: '$label：',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: '$label：',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            TextSpan(
              text: url,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnsRow(SnsInfo sns) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: '${sns.name}：',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            TextSpan(
              text: sns.display,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final uri = Uri.parse(sns.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
            ),
          ],
        ),
      ),
    );
  }
}
