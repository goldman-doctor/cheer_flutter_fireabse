import 'package:cheer/themes/light_color.dart';
import 'package:cheer/themes/theme.dart';
import 'package:cheer/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:cheer/screens/mainpage.dart';

class ChildPage extends StatefulWidget {
  const ChildPage({super.key});
  @override
  State<ChildPage> createState() => _ChildPageState();
}

class _ChildPageState extends State<ChildPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: AppTheme.fullWidth(context),
          height: AppTheme.fullHeight(context),
          decoration: BoxDecoration(color: LightColor.background),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              TitleText(
                text: 'Cheermee_test',
                fontSize: 30,
                textAlign: TextAlign.center,
                color: LightColor.orange,
              ),
              SizedBox(height: 5),
              TitleText(
                text: 'Cheermmeeへようこそ！',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleText(
                    text: 'Cheermeeは、べんきょうやおてつだいなど',
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 4),
                  TitleText(
                    text: 'がんばりたぢことをつづけられるアプリです。',
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: AppTheme.fullWidth(context) / 3,
                height: AppTheme.fullHeight(context) / 5,

                child: Image.asset('assets/child.png'),
              ),
              SizedBox(height: 10),
              TitleText(
                text: 'ログインするためのQRコードまたはURLを',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              TitleText(
                text: 'おうちの人が出してくれるまで',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              TitleText(
                text: 'このままていてね！',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              Customtextbutton(
                text: '戻る',
                color: const Color.fromARGB(255, 73, 189, 79),
                bordercolor: const Color.fromARGB(255, 73, 189, 79),
                backgroundcolor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
