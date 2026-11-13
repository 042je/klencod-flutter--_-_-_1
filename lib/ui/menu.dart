import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/pixel.dart';
import '../core/theme.dart';
import '../game/game.dart';
import 'common.dart';
import 'shell.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool hasAuto = false, hasManual = false;
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final a = await Game.hasSave('save_auto');
    final m = await Game.hasSave('save_manual');
    if (mounted) setState(() {
      hasAuto = a;
      hasManual = m;
    });
  }

  Future<void> _load(String slot) async {
    final ok = await game.load(slot);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Shell()));
    } else {
      toast(context, 'تعذر تحميل الحفظ.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const Positioned.fill(
            child: SceneView(biome: 'mountain', look: Look(robe: 6, hair: 2), height: 900)),
        Positioned.fill(child: Container(color: const Color(0x99000000))),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/img/logo.png',
                    width: 130,
                    height: 130,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 10)),
                const SizedBox(height: 8),
                Text('طريق الخلود', style: ts(s: 38, b: true, c: C.gold)),
                Text('حياة · عائلة · زراعة روحية · مرآة الأقدار',
                    style: ts(s: 13, c: C.dim)),
                const SizedBox(height: 30),
                if (hasAuto || hasManual)
                  PixelButton('متابعة', color: C.jade.withAlpha(160),
                      onTap: () => _load(hasAuto ? 'save_auto' : 'save_manual')),
                PixelButton('لعبة جديدة', onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const CreateScreen()))
                      .then((_) => _check());
                }),
                if (hasManual)
                  PixelButton('تحميل الحفظ اليدوي', onTap: () => _load('save_manual')),
                PixelButton('الإعدادات', onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: Dialog(
                              backgroundColor: Colors.transparent,
                              child: PixelPanel(
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Text('الإعدادات', style: ts(s: 18, b: true, c: C.gold)),
                                const SizedBox(height: 8),
                                Text(
                                    'اللعبة تعمل بالكامل دون إنترنت. الحفظ تلقائي كل شهر داخل اللعبة، ويمكنك الحفظ اليدوي من قائمة «المزيد».',
                                    style: ts(s: 13)),
                                PixelButton('حسناً', onTap: () => Navigator.pop(context)),
                              ])))));
                }),
                PixelButton('خروج', color: C.red.withAlpha(150),
                    onTap: () => SystemNavigator.pop()),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final nameC = TextEditingController(text: 'لين فنغ');
  bool male = true;
  int skin = 0, hair = 0, robe = 0, style = 0;
  final alloc = {'str': 0, 'wis': 0, 'cha': 0, 'luck': 0};
  static const total = 12;
  int get left => total - alloc.values.fold<int>(0, (a, b) => a + b);

  Look get look => Look(skin: skin, hair: hair, robe: robe, style: style, female: !male);

  Widget _cycle(String label, int v, int n, void Function(int) set) {
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: ts(c: C.dim))),
      PixelButton('‹', small: true, onTap: () => setState(() => set((v + n - 1) % n))),
      Text('${v + 1}', style: ts(b: true)),
      PixelButton('›', small: true, onTap: () => setState(() => set((v + 1) % n))),
    ]);
  }

  Widget _stat(String k, String label) {
    return Row(children: [
      SizedBox(width: 70, child: Text(label, style: ts())),
      PixelButton('−', small: true, onTap: () => setState(() {
            if (alloc[k]! > 0) alloc[k] = alloc[k]! - 1;
          })),
      SizedBox(width: 36, child: Center(child: Text('${3 + alloc[k]!}', style: ts(b: true, c: C.gold)))),
      PixelButton('+', small: true, onTap: () => setState(() {
            if (left > 0) alloc[k] = alloc[k]! + 1;
          })),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'إنشاء الشخصية',
      body: ListView(padding: const EdgeInsets.all(12), children: [
        ClipRect(child: SceneView(biome: 'village', look: look, height: 140)),
        const SizedBox(height: 8),
        PixelPanel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              controller: nameC,
              maxLength: 16,
              style: ts(s: 16),
              decoration: const InputDecoration(labelText: 'الاسم', counterText: ''),
            ),
            Row(children: [
              Expanded(
                  child: PixelButton('ذكر',
                      color: male ? C.jade.withAlpha(160) : C.border,
                      onTap: () => setState(() => male = true))),
              Expanded(
                  child: PixelButton('أنثى',
                      color: !male ? C.jade.withAlpha(160) : C.border,
                      onTap: () => setState(() => male = false))),
            ]),
            _cycle('البشرة', skin, kSkins.length, (v) => skin = v),
            _cycle('الشعر', hair, kHairs.length, (v) => hair = v),
            _cycle('الثوب', robe, kRobes.length, (v) => robe = v),
            _cycle('التسريحة', style, 3, (v) => style = v),
          ]),
        ),
        PixelPanel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('وزّع $left نقطة', style: ts(b: true, c: C.gold)),
            _stat('str', 'القوة'),
            _stat('wis', 'الحكمة'),
            _stat('cha', 'السحر'),
            _stat('luck', 'الحظ'),
            const SizedBox(height: 4),
            Text('القوة تقوّي القتال، والحكمة تسرّع الزراعة، والسحر يخدم العلاقات، والحظ يفتح الفرص.',
                style: ts(s: 12, c: C.dim)),
          ]),
        ),
        PixelButton('ابدأ الحياة', color: C.jade.withAlpha(170), onTap: () {
          final nm = nameC.text.trim().isEmpty ? 'مجهول' : nameC.text.trim();
          game.newGame(nm, male, look, Map<String, int>.from(alloc));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
        }),
      ]),
    );
  }
}
