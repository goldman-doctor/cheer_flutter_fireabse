import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  PrivacyPolicyScreen({Key? key}) : super(key: key);
  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final String title = 'プライバシーポリシー';

  final List<Map<String, dynamic>> policySections = [
    {
      'header': '1. 収集する情報',
      'content': [
        '当社は、以下の情報を収集することがあります。',
        '・お客様が入力する情報（例：ユーザー名、メールアドレスなど）',
        '・利用状況に関する情報（例：アプリの使用履歴）',
      ],
    },
    {
      'header': '2. 情報の利用目的',
      'content': [
        '収集した情報は、以下の目的で利用します。',
        '・サービスの提供・改善のため',
        '・お問い合わせ対応のため',
        '・法令遵守のため',
      ],
    },
    {
      'header': '3. 情報の第三者提供',
      'content': ['当社は、法令に基づく場合を除き、お客様の同意なく第三者に情報を提供いたしません。'],
    },
    {
      'header': '4. 情報の管理',
      'content': ['お客様の個人情報は、安全に管理し、不正アクセス、紛失、改ざん等を防止するために適切な措置を講じます。'],
    },
    {
      'header': '5. お問い合わせ',
      'content': [
        '本プライバシーポリシーに関するお問い合わせは、下記までお願いいたします。',
        'メール：info@startinnovation.jp',
        '住所：東京都品川区東大井4-4-11-205',
        '電話番号：+81 80-3247-9274',
      ],
    },
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
              'プライバシーポシー',
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: policySections.map((section) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildSection(section['header'], section['content']),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String header, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        ...content.map(
          (line) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(line, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
