import 'package:flutter/material.dart';
import '../core/pixel.dart';
import '../core/sprites.dart';
import '../core/theme.dart';
import '../data/cultivation.dart';
import '../data/world.dart';
import '../game/game.dart';
import 'common.dart';
import 'extras_ui.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  Widget _entry(BuildContext c, String t, String sub, Widget Function() page) {
    return GestureDetector(
      onTap: () {
        tap();
        Navigator.of(c).push(MaterialPageRoute(builder: (_) => page()));
      },
      child: PixelPanel(
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: ts(s: 16, b: true)),
              Text(sub, style: ts(s: 12, c: C.dim)),
            ]),
          ),
          const Icon(Icons.chevron_left, color: C.dim),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(10), children: [
      _entry(context, 'حملة المعارك', 'مراحل متتالية بفريقك وحيوانك الأليف', () => const CampaignScreen()),
      _entry(context, 'الفريق', 'رفاق يقاتلون معك', () => const TeamScreen()),
      _entry(context, 'الحيوانات الأليفة', 'بيض وفقس وتطوير', () => const PetsScreen()),
      _entry(context, 'المهارات والتقنيات', 'تعلّم وارفع الإتقان', () => const SkillsScreen()),
      _entry(context, 'فرن صقل الحبوب', 'اصقل الحبوب وطوّر الفرن', () => const FurnaceScreen()),
      _entry(context, 'الحداد', 'أسلحة ودروع وتحسين', () => const SmithScreen()),
      _entry(context, 'أراضي الفانين', 'ساعدهم وخذ الموارد وجنّد الرفاق', () => const MortalsScreen()),
      _entry(context, 'المكافأة اليومية', 'سبعة أيام متتالية', () => const DailyScreen()),
      _entry(context, 'الخريطة والسفر', 'تنقّل بين المناطق واكتشف المخفي', () => const MapScreen()),
      _entry(context, 'ملف الشخصية', 'الصفات والعمر والإحصاءات', () => const ProfileScreen()),
      _entry(context, 'الطوائف', 'انضم وارتقِ في الرتب', () => const SectScreen()),
      _entry(context, 'الأهداف', 'مهام الحياة الكبرى', () => const GoalsScreen()),
      _entry(context, 'مرآة الأقدار', 'ترقيات دائمة ومعارف الحيوات', () => const MirrorScreen()),
      _entry(context, 'سجل الحيوات', 'كل ما عشته من قبل', () => const LivesScreen()),
      _entry(context, 'الحفظ والإعدادات', 'حفظ يدوي وتحميل', () => const SettingsScreen()),
    ]);
  }
}

// ---------------- الخريطة ----------------
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String sel = game.regionId;

  @override
  Widget build(BuildContext context) {
    final g = game;
    final r = region(sel);
    return GameScaffold(
      title: 'الخريطة',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(10), children: [
          PixelPanel(
            padding: EdgeInsets.zero,
            child: AspectRatio(
              aspectRatio: 1.05,
              child: LayoutBuilder(builder: (context, cons) {
                return GestureDetector(
                  onTapUp: (d) {
                    String? best;
                    double bd = 40;
                    for (final rg in regions) {
                      if (!g.found.contains(rg.id)) continue;
                      final dx = rg.mx * cons.maxWidth - d.localPosition.dx;
                      final dy = rg.my * cons.maxHeight - d.localPosition.dy;
                      final dist = (dx * dx + dy * dy);
                      if (dist < bd * bd) {
                        bd = dist;
                        best = rg.id;
                      }
                    }
                    if (best != null) setState(() => sel = best!);
                  },
                  child: CustomPaint(
                      size: Size(cons.maxWidth, cons.maxHeight),
                      painter: _MapPainter(g.found, g.regionId, sel)),
                );
              }),
            ),
          ),
          PixelPanel(
            borderColor: C.gold,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                SpriteIcon(regionSprites[r.icon] ?? regionSprites['plain']!, size: 36),
                const SizedBox(width: 8),
                Expanded(child: Text(r.name, style: ts(s: 17, b: true, c: C.gold))),
                Tag(kingdomNames[r.kingdom] ?? '', color: C.purple),
              ]),
              Text(r.desc, style: ts(s: 12, c: C.dim)),
              StatLine('مستوى الخطر', '${r.level}'),
              StatLine('كثافة الطاقة', r.density.toStringAsFixed(1)),
              StatLine('سوق', r.market ? 'نعم' : 'لا'),
              if (sel != g.regionId) ...[
                StatLine('مدة السفر', '${g.travelMonths(sel)} شهر'),
                StatLine('التكلفة', '${g.travelMonths(sel) * 6} فضة'),
                PixelButton('سافر إلى هنا', color: C.jade.withAlpha(170), onTap: () {
                  run(context, () => g.travel(sel));
                  setState(() {});
                }),
              ] else
                Text('أنت هنا الآن.', style: ts(c: C.jade, b: true)),
            ]),
          ),
          Text('المناطق المكتشفة: ${g.found.length}/${regions.length}',
              style: ts(s: 12, c: C.dim)),
        ]),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Set<String> found;
  final String cur, sel;
  _MapPainter(this.found, this.cur, this.sel);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF1A2540);
    canvas.drawRect(Offset.zero & size, bg);
    // مناطق الممالك
    final cols = {
      'dawnreach': const Color(0xFF244A3A),
      'ashenhold': const Color(0xFF4A2A2A),
      'silverfjord': const Color(0xFF2A3A5A),
    };
    final kp = Paint();
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height), kp..color = cols['dawnreach']!);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.38, 0, size.width * 0.34, size.height * 0.55),
        kp..color = cols['ashenhold']!.withAlpha(200));
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.68, 0, size.width * 0.32, size.height),
        kp..color = cols['silverfjord']!.withAlpha(210));
    final lp = Paint()
      ..color = const Color(0xFFB8A878)
      ..strokeWidth = 3;
    for (final e in edges) {
      if (!found.contains(e.a) || !found.contains(e.b)) continue;
      final a = region(e.a), b = region(e.b);
      canvas.drawLine(Offset(a.mx * size.width, a.my * size.height),
          Offset(b.mx * size.width, b.my * size.height), lp);
    }
    for (final rg in regions) {
      if (!found.contains(rg.id)) continue;
      final p = Offset(rg.mx * size.width, rg.my * size.height);
      final sp = regionSprites[rg.icon] ?? regionSprites['plain']!;
      if (rg.id == sel) {
        canvas.drawRect(Rect.fromCenter(center: p, width: 40, height: 40),
            Paint()..color = const Color(0x55E8C766));
      }
      paintSprite(canvas, sp, p.dx - 15, p.dy - 15, 3);
      if (rg.id == cur) {
        canvas.drawRect(Rect.fromLTWH(p.dx - 5, p.dy - 28, 10, 10), Paint()..color = const Color(0xFFE0524E));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}

// ---------------- ملف الشخصية ----------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'ملف الشخصية',
      body: ListView(padding: const EdgeInsets.all(10), children: [
        PixelPanel(
          child: Row(children: [
            Portrait(g.look, size: 80),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.name, style: ts(s: 20, b: true, c: C.gold)),
                Text('${g.male ? 'ذكر' : 'أنثى'} · الجيل ${g.generation}', style: ts(c: C.dim, s: 12)),
                Text('${realms[g.realm].name} - ${subName(g.realm, g.sub)}', style: ts(c: C.jade, b: true)),
              ]),
            ),
          ]),
        ),
        PixelPanel(
          child: Column(children: [
            StatLine('العمر', '${g.age} (${ageStage(g.age, g.lifespan)})'),
            StatLine('العمر المتوقع', '${g.lifespan} سنة'),
            StatLine('القوة', '${g.str}'),
            StatLine('الحكمة', '${g.wis}'),
            StatLine('السحر', '${g.cha}'),
            StatLine('الحظ', '${g.luck}'),
            StatLine('القوة القتالية', '${g.power.round()}'),
            StatLine('المهنة', jobOf(g.job).name),
            StatLine('الطائفة', g.sect.isEmpty ? 'لا شيء' : '${sectDefs.firstWhere((s) => s.id == g.sect).name} (${sectRanks[g.sectRank]})'),
            StatLine('الأبناء', '${g.children.length}'),
            StatLine('المواقع المقتحمة', '${g.stat['sites'] ?? 0}'),
            StatLine('الجذر الروحي', g.realm >= 1 ? '${rootNames[g.rootEl]} (${purityNames[g.purity]})' : 'غير مكتشف'),
          ]),
        ),
        const Heading('أهم قراراتك'),
        for (final d in g.decisions.reversed.take(8)) Text('• $d', style: ts(s: 12, c: C.dim)),
      ]),
    );
  }
}

// ---------------- الطوائف ----------------
class SectScreen extends StatelessWidget {
  const SectScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'الطوائف',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(10), children: [
          if (g.sect.isNotEmpty)
            PixelPanel(
              borderColor: C.gold,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sectDefs.firstWhere((s) => s.id == g.sect).name, style: ts(s: 17, b: true, c: C.gold)),
                StatLine('الرتبة', sectRanks[g.sectRank]),
                StatLine('المساهمة', '${g.sectContrib}'),
                Text('راتب شهري وزيادة 10% في التدريب. الترقية تحتاج مساهمات.', style: ts(s: 12, c: C.dim)),
                Wrap(children: [
                  PixelButton('أنجز مهمة (فعل)', small: true, onTap: () => run(context, g.sectMission)),
                  PixelButton('غادر الطائفة', small: true, color: C.red.withAlpha(160),
                      onTap: () => run(context, g.leaveSect)),
                ]),
              ]),
            ),
          for (final s in sectDefs)
            PixelPanel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: ts(s: 16, b: true)),
                Text(s.desc, style: ts(s: 12, c: C.dim)),
                Text('المكان: ${region(s.region).name} · يتطلب ${realms[s.needRealm].name}',
                    style: ts(s: 12, c: C.dim)),
                if (g.sect.isEmpty)
                  PixelButton('انضم', small: true, onTap: () => run(context, () => g.joinSect(s))),
              ]),
            ),
        ]),
      ),
    );
  }
}

// ---------------- الأهداف ----------------
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final goals = game.goals();
    return GameScaffold(
      title: 'الأهداف',
      body: ListView(padding: const EdgeInsets.all(10), children: [
        for (final gl in goals)
          PixelPanel(
            borderColor: gl[1] == true ? C.jade : C.border,
            child: Row(children: [
              Icon(gl[1] == true ? Icons.check_box : Icons.check_box_outline_blank,
                  color: gl[1] == true ? C.jade : C.dim),
              const SizedBox(width: 8),
              Expanded(child: Text(gl[0] as String, style: ts(s: 14))),
            ]),
          ),
      ]),
    );
  }
}

// ---------------- مرآة الأقدار ----------------
class MirrorScreen extends StatelessWidget {
  const MirrorScreen({super.key});
  static const kn = {
    'lotus': 'موقع وتوقيت لوتس الفجر في كهف اللوتس',
    'stranger': 'هوية الغريب وي لان',
    'void_gate_path': 'الطريق إلى ما بعد حدود الزراعة (البوابة الفارغة)',
    'void_gate_seen': 'رأيت البوابة الفارغة من الداخل',
    'immortal': 'بلغت الخلود',
  };
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'مرآة الأقدار',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(10), children: [
          PixelPanel(
            borderColor: C.purple,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('أصداء القدر: ${g.echo}', style: ts(s: 18, b: true, c: C.purple)),
              Text('تكسبها عند موت كل حياة بحسب إنجازاتك. تُنفق على ترقيات تبقى في كل حياة قادمة.',
                  style: ts(s: 12, c: C.dim)),
            ]),
          ),
          const Heading('الترقيات الدائمة'),
          for (final id in perkIds)
            PixelPanel(
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(perkNames[id]!, style: ts(s: 13, b: true)),
                    Text('المستوى ${g.perk(id)}/5', style: ts(s: 12, c: C.dim)),
                  ]),
                ),
                PixelButton(g.perk(id) >= 5 ? 'أقصى' : '${g.perkCost(id)} ✦', small: true,
                    color: C.purple.withAlpha(170),
                    onTap: g.perk(id) >= 5
                        ? null
                        : () {
                            final ok = g.buyPerk(id);
                            toast(context, ok ? 'تمت الترقية! تسري في الحياة القادمة.' : 'أصداؤك لا تكفي.');
                          }),
              ]),
            ),
          const Heading('المعارف المكتسبة'),
          if (g.knowledge.isEmpty)
            Text('لا معارف بعد. بعض الأسرار لا تنكشف إلا بتكرار الحيوات.', style: ts(c: C.dim)),
          for (final k in g.knowledge)
            PixelPanel(child: Text('✦ ${kn[k] ?? k}', style: ts(s: 13, c: C.gold))),
        ]),
      ),
    );
  }
}

// ---------------- سجل الحيوات ----------------
class LivesScreen extends StatelessWidget {
  const LivesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'سجل الحيوات',
      body: ListView(padding: const EdgeInsets.all(10), children: [
        Text('عدد الحيوات المنتهية: ${g.lives.length}', style: ts(b: true, c: C.gold)),
        if (g.lives.isEmpty) Text('لم تمت بعد.', style: ts(c: C.dim)),
        for (int i = g.lives.length - 1; i >= 0; i--)
          PixelPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('الحياة ${i + 1}: ${g.lives[i]['name']}', style: ts(s: 15, b: true)),
              StatLine('العمر', '${g.lives[i]['age']}'),
              StatLine('المرحلة', '${g.lives[i]['realm']} - ${g.lives[i]['sub']}'),
              StatLine('الثروة', '${g.lives[i]['silver']}'),
              StatLine('المهنة', '${g.lives[i]['job']}'),
              StatLine('الأبناء', '${g.lives[i]['children']}'),
              StatLine('السبب', '${g.lives[i]['cause']}', color: C.red),
              StatLine('أصداء مكتسبة', '${g.lives[i]['gain']}', color: C.purple),
              for (final d in (g.lives[i]['decisions'] as List)) Text('• $d', style: ts(s: 11, c: C.dim)),
            ]),
          ),
      ]),
    );
  }
}

// ---------------- الإعدادات ----------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'الحفظ والإعدادات',
      body: ListView(padding: const EdgeInsets.all(10), children: [
        PixelPanel(
          child: Column(children: [
            Text('الحفظ التلقائي يتم كل شهر.', style: ts(c: C.dim)),
            PixelButton('حفظ يدوي', color: C.jade.withAlpha(170), onTap: () async {
              await g.save('save_manual');
              if (context.mounted) toast(context, 'تم الحفظ.');
            }),
            PixelButton('تحميل الحفظ اليدوي', onTap: () async {
              final ok = await g.load('save_manual');
              if (context.mounted) toast(context, ok ? 'تم التحميل.' : 'لا حفظ يدوي.');
            }),
          ]),
        ),
        PixelButton('العودة إلى القائمة الرئيسية', color: C.red.withAlpha(150), onTap: () {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }),
      ]),
    );
  }
}

// ---------------- شاشة الموت ----------------
class DeathScreen extends StatelessWidget {
  const DeathScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return PopScope(
      canPop: false,
      child: ListenableBuilder(
        listenable: g,
        builder: (context, _) => GameScaffold(
          back: false,
          title: 'انتهت الحياة',
          body: ListView(padding: const EdgeInsets.all(12), children: [
            PixelPanel(
              borderColor: C.red,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${g.name} رحل عن الدنيا', style: ts(s: 20, b: true, c: C.red)),
                Text('السبب: ${g.deathCause}', style: ts(s: 14)),
                const SizedBox(height: 6),
                StatLine('العمر', '${g.age}'),
                StatLine('المرحلة', '${realms[g.realm].name} - ${subName(g.realm, g.sub)}'),
                StatLine('الثروة', '${g.silver}'),
                StatLine('الأبناء', '${g.children.length}'),
                StatLine('أصداء القدر المكتسبة', '+${g.echoGain}', color: C.purple),
              ]),
            ),
            Text('ترى بريق مرآة الأقدار أمامك... ماذا تختار؟', style: ts(s: 14, c: C.gold)),
            const SizedBox(height: 6),
            PixelButton('اشترِ ترقيات من المرآة', color: C.purple.withAlpha(170), onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MirrorScreen()));
            }),
            PixelButton('ارجع بالزمن (حياة جديدة بالذاكرة)', color: C.jade.withAlpha(170), onTap: () {
              g.rewind();
              Navigator.of(context).pop();
            }),
            if (g.heirs.isNotEmpty) ...[
              const Heading('أو استمر عبر وريث'),
              for (final c in g.heirs)
                personCard(c, [
                  PixelButton('تولَّ دور ${c.name}', small: true, color: C.orange.withAlpha(170), onTap: () {
                    g.continueAs(c);
                    Navigator.of(context).pop();
                  }),
                ], sub: 'الموهبة ${c.talent} · المهارة ${c.skill}'),
            ],
            PixelButton('القائمة الرئيسية', onTap: () => Navigator.of(context).pop('menu')),
          ]),
        ),
      ),
    );
  }
}
