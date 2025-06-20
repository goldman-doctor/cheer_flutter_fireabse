import 'package:cheer/themes/light_color.dart';
import 'package:cheer/themes/theme.dart';
import 'package:cheer/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:cheer/screens/parent/parentpage.dart';
import 'package:cheer/widgets/customtextbutton.dart';
import 'package:cheer/screens/child/childpage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Image adultImage;
  late Image childImage;
  @override
  void initState() {
    super.initState();
    adultImage = Image.asset('assets/loading.png', fit: BoxFit.contain);
    childImage = Image.asset('assets/child.png', fit: BoxFit.contain);

    // Precache images so they're loaded before build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(adultImage.image, context);
      precacheImage(childImage.image, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = AppTheme.fullWidth(context);
    final height = AppTheme.fullHeight(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: LightColor.background),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // Spread items vertically
            children: [
              // Top title section
              Column(
                children: [
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
                ],
              ),

              // Info text section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleText(
                    text: 'Cheermeeは、おとなが使う端末と子どもが使う端末の両方に',
                    fontSize: 15,
                    color: Colors.black87,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  TitleText(
                    text: 'アプリがダウンロードされている必要があります',
                    fontSize: 15,
                    color: Colors.black87,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Adult section
              Expanded(
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width * 0.6,
                        maxHeight: height * 0.25,
                      ),
                      child: childImage,
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: width * 0.6,
                      child: Customtextbutton(
                        text: 'おとなはここをタップ!',
                        color: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Parentpage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Child section
              Expanded(
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width * 0.6,
                        maxHeight: height * 0.25,
                      ),
                      child: adultImage,
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: width * 0.6,
                      child: Customtextbutton(
                        text: 'こどもはここをタップ！',
                        fontSize: 14,
                        backgroundcolor: Color.fromRGBO(69, 231, 83, 1),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChildPage(),
                            ),
                          );
                        },
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
