import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:provider/provider.dart';

import '../../widgets/faq_screen_widget/faq_widget.dart';
import '../../widgets/faq_screen_widget/add_faq_widget.dart';
import '../../widgets/layout_widget/app_header.dart';
import '../../theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FAQScreen(),
    ),
  );
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AddFAQWidget(),
            SizedBox(height: 16),
            FAQWidget(),
          ],
        ),
      ),
    );
  }
}
