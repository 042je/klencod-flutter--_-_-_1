import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'ui/menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'طريق الخلود',
      theme: buildTheme(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox()),
      home: const MenuScreen(),
    );
  }
}