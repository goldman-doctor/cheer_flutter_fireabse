import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  TermsOfServicePage({super.key});

  // The terms text split by paragraphs for better formatting
  final List<String> termsParagraphs = [
    'Cheermee（チアミー）利用規約',
    '第1条（適用）\n本規約は、株式会社Cheermee（以下「当社」といいます）が提供するサービス「Cheermee」（以下「本サービス」といいます）の利用条件を定めるものです。ユーザーは本規約に同意のうえ本サービスを利用するものとします。',
    '第2条（利用登録）\n1. 本サービスの利用には、当社が定める方法による利用登録が必要です。\n2. 当社は、以下の場合には利用登録を拒否することがあります。\n　(1) 過去に本規約違反等で利用停止処分を受けた場合\n　(2) 虚偽の情報を登録した場合\n　(3) その他当社が登録を不適当と判断した場合',
    '第3条（禁止事項）\nユーザーは本サービスの利用に際し、以下の行為をしてはなりません。\n1. 法令または公序良俗に違反する行為\n2. 犯罪行為に関連する行為\n3. 他のユーザーや第三者の権利を侵害する行為\n4. 本サービスの運営を妨害する行為\n5. 虚偽の情報を提供する行為\n6. その他当社が不適切と判断する行為',
    '第4条（サービスの提供）\n当社は本サービスを適切に提供するよう努めますが、保守・更新・障害等によりサービスを一時停止することがあります。当社はこれにより生じた損害について責任を負いません。',
    '第5条（料金・支払い）\n本サービスの基本利用は無料ですが、一部有料サービスを提供する場合があります。有料サービスの料金および支払い方法は別途定めます。',
    '第6条（免責事項）\n当社は、本サービスの利用により発生したトラブルや損害について、一切責任を負いません。また、サービスの内容の正確性や安全性を保証しません。',
    '第7条（著作権）\n本サービスに関する著作権その他の知的財産権は当社または権利者に帰属します。無断で複製・転載・改変することはできません。',
    '第8条（個人情報の取り扱い）\n当社は、別途定めるプライバシーポリシーに従い、ユーザーの個人情報を適切に取り扱います。',
    '第9条（契約の解除）\nユーザーが本規約に違反した場合、当社は利用契約を解除し、サービスの利用を停止することができます。',
    '第10条（準拠法・裁判管轄）\n本規約は日本法に準拠し、本サービスに関する紛争は東京地方裁判所を専属的合意管轄裁判所とします。',
    '附則\n本規約は2025年6月18日より施行します。',
  ];

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
              '利用規約',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          child: ListView.separated(
            itemCount: termsParagraphs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final text = termsParagraphs[index];
              // Make the first item bold and larger font (title)
              if (index == 0) {
                return Text(
                  text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                );
              }
              // For other paragraphs, normal text style
              return Text(
                text,
                style: const TextStyle(fontSize: 16, height: 1.5),
              );
            },
          ),
        ),
      ),
    );
  }
}
