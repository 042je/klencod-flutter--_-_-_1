import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class C {
  static const Color bg = Color(0xFF0D0A17);
  static const Color panel = Color(0xFF1B1630);
  static const Color panel2 = Color(0xFF282044);
  static const Color border = Color(0xFF5B4B9A);
  static const Color borderHi = Color(0xFF9D86F0);
  static const Color gold = Color(0xFFE8C766);
  static const Color jade = Color(0xFF5FD3A0);
  static const Color red = Color(0xFFE0524E);
  static const Color blue = Color(0xFF58B0FF);
  static const Color purple = Color(0xFFB07CFF);
  static const Color orange = Color(0xFFFF9A4D);
  static const Color text = Color(0xFFEDE6FF);
  static const Color dim = Color(0xFF9C94BD);
  static const Color black = Color(0xFF000000);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: C.bg,
    colorScheme: ColorScheme.fromSeed(
        seedColor: C.border, brightness: Brightness.dark),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: C.text, fontSize: 14, height: 1.35),
    ),
  );
}

TextStyle ts(
        {double s = 14,
        Color c = C.text,
        bool b = false,
        double h = 1.35}) =>
    TextStyle(
        fontSize: s,
        color: c,
        height: h,
        fontWeight: b ? FontWeight.bold : FontWeight.normal);

void tap() {
  HapticFeedback.selectionClick();
}

void buzz() {
  HapticFeedback.mediumImpact();
}

/// حاوية بإطار بكسل
class PixelPanel extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  const PixelPanel(
      {super.key,
      required this.child,
      this.color = C.panel,
      this.borderColor = C.border,
      this.padding = const EdgeInsets.all(10),
      this.margin = const EdgeInsets.only(bottom: 8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [
          BoxShadow(color: C.black, offset: Offset(3, 3), blurRadius: 0)
        ],
      ),
      child: child,
    );
  }
}

class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool small;
  final IconData? icon;
  const PixelButton(this.label,
      {super.key,
      this.onTap,
      this.color = C.border,
      this.small = false,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final en = onTap != null;
    return GestureDetector(
      onTap: en
          ? () {
              tap();
              onTap!();
            }
          : null,
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: EdgeInsets.symmetric(
            horizontal: small ? 10 : 14, vertical: small ? 6 : 10),
        decoration: BoxDecoration(
          color: en ? color : const Color(0xFF3A3550),
          border: Border.all(
              color: en ? C.borderHi : const Color(0xFF55506B), width: 2),
          boxShadow: const [
            BoxShadow(color: C.black, offset: Offset(2, 2), blurRadius: 0)
          ],
        ),
        child: LayoutBuilder(builder: (context, cons) {
          final label0 = Text(label,
              textAlign: TextAlign.center,
              style: ts(s: small ? 12 : 14, b: true, c: en ? C.text : C.dim));
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: small ? 14 : 18, color: C.text),
                const SizedBox(width: 6),
              ],
              // Flexible يسبب استثناء إن كان العرض غير محدود (داخل Row)
              if (cons.hasBoundedWidth) Flexible(child: label0) else label0,
            ],
          );
        }),
      ),
    );
  }
}

class PixelBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final String? label;
  final double height;
  const PixelBar(
      {super.key,
      required this.value,
      required this.color,
      this.label,
      this.height = 14});

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF110D1E),
        border: Border.all(color: C.black, width: 2),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: v,
            child: Container(color: color),
          ),
          if (label != null)
            Center(
              child: Text(label!,
                  style: ts(s: height - 4 > 12 ? 11 : height - 3, b: true)),
            ),
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  const Tag(this.text, {super.key, this.color = C.border});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 4, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        color: color,
        child: Text(text, style: ts(s: 11, b: true)),
      );
}

class Heading extends StatelessWidget {
  final String text;
  final Color color;
  const Heading(this.text, {super.key, this.color = C.gold});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
        child: Row(children: [
          Container(width: 6, height: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: ts(s: 16, b: true, c: color))),
        ]),
      );
}

/// هيكل شاشة موحد بشريط عنوان
class GameScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool back;
  const GameScaffold(
      {super.key,
      required this.title,
      required this.body,
      this.actions,
      this.back = true});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: C.bg,
        appBar: AppBar(
          backgroundColor: C.panel,
          elevation: 0,
          automaticallyImplyLeading: false,
          shape: const Border(bottom: BorderSide(color: C.border, width: 3)),
          title: Text(title, style: ts(s: 18, b: true, c: C.gold)),
          actions: actions,
          leading: back
              ? IconButton(
                  icon: const Icon(Icons.arrow_forward, color: C.text),
                  onPressed: () => Navigator.of(context).maybePop())
              : null,
        ),
        body: SafeArea(child: body),
      ),
    );
  }
}

void toast(BuildContext context, String msg) {
  final m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    backgroundColor: C.panel2,
    duration: const Duration(milliseconds: 2200),
    shape: const Border.fromBorderSide(BorderSide(color: C.borderHi, width: 2)),
    content: Directionality(
        textDirection: TextDirection.rtl, child: Text(msg, style: ts())),
  ));
}

Future<bool> confirmDialog(BuildContext context, String title, String msg,
    {String yes = 'نعم', String no = 'لا'}) async {
  final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: PixelPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ts(s: 17, b: true, c: C.gold)),
                    const SizedBox(height: 8),
                    Text(msg, style: ts()),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: PixelButton(yes,
                              color: C.jade.withAlpha(150),
                              onTap: () => Navigator.pop(ctx, true))),
                      Expanded(
                          child: PixelButton(no,
                              onTap: () => Navigator.pop(ctx, false))),
                    ])
                  ],
                ),
              ),
            ),
          ));
  return r ?? false;
}
