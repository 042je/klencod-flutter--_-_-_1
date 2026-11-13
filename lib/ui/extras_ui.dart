import 'dart:math';
import 'package:flutter/material.dart';
import '../core/pixel.dart';
import '../core/sprites.dart';
import '../core/theme.dart';
import '../data/extras_data.dart';
import '../data/items.dart';
import '../data/techniques.dart';
import '../game/extras.dart';
import '../game/game.dart';
import 'common.dart';

const List<String> _stageBiomes = ['plains', 'forest', 'cave', 'ruins', 'swamp', 'snow', 'void'];
const List<String> _mateWeapons = ['sword', 'staff', 'staff', 'bow'];

// ======================= الحملة =======================
class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});
  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  BattleInfo? info;
  bool playing = false;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _fight(bool farm) {
    if (playing) return;
    final r = game.campaign(farm: farm);
    if (r.err.isNotEmpty) {
      toast(context, r.err);
      return;
    }
    buzz();
    setState(() {
      info = r;
      playing = true;
      showResult = false;
    });
    _c.forward(from: 0).then((_) {
      game.changed();
      if (!mounted) return;
      setState(() {
        playing = false;
        showResult = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'حملة المعارك',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) {
          final st = info != null && (playing || showResult) ? info!.stage : g.stage;
          final shownBoss = st % 10 == 0;
          return ListView(padding: const EdgeInsets.all(10), children: [
            PixelPanel(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 190,
                child: ClipRect(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _BattlePainter(
                        _c, playing || showResult ? info : null, g.look,
                        g.weapon.isEmpty ? 'sword' : item(g.weapon).wtype,
                        g.mates, g.activePet?.id, st),
                  ),
                ),
              ),
            ),
            PixelPanel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('المرحلة $st${shownBoss ? '  (زعيم)' : ''}', style: ts(s: 18, b: true, c: shownBoss ? C.red : C.gold))),
                  Tag('أفضل مرحلة ${g.lv('best')}', color: C.purple),
                ]),
                StatLine('قوتك (مع الفريق)', '${g.power.round()}'),
                StatLine('قوة العدو التقريبية', '${g.stageEnemyPower(st).round()}',
                    color: g.power >= g.stageEnemyPower(st) ? C.jade : C.red),
                StatLine('الصحة', '${g.health}/${g.maxHealth}'),
                StatLine('نقاط الفعل', '${g.ap}'),
              ]),
            ),
            if (showResult && info != null)
              PixelPanel(
                borderColor: info!.win ? C.jade : C.red,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(info!.win ? 'انتصار على ${info!.name}!' : 'خسارة أمام ${info!.name}',
                      style: ts(s: 16, b: true, c: info!.win ? C.jade : C.red)),
                  Text(info!.rewards, style: ts(s: 13)),
                ]),
              ),
            Wrap(children: [
              PixelButton('قاتل المرحلة ${g.stage}', color: C.red.withAlpha(180), onTap: playing ? null : () => _fight(false)),
              PixelButton('كرّر المرحلة ${g.stage - 1} (غنائم أقل)', small: true,
                  onTap: playing || g.stage <= 1 ? null : () => _fight(true)),
            ]),
            const Heading('فريقك'),
            Wrap(children: [
              Column(children: [
                Portrait(g.look, size: 54),
                Text('أنت', style: ts(s: 11)),
              ]),
              for (final m in g.mates)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(children: [
                    Portrait(m.look, size: 54),
                    Text('${mateClasses[m.talent]} ${m.skill}', style: ts(s: 11)),
                  ]),
                ),
              if (g.activePet != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(children: [
                    Container(
                        width: 54,
                        height: 54,
                        color: C.panel2,
                        child: SpriteIcon(petSprites[g.activePet!.id]!, size: 44)),
                    Text(g.activePet!.name, style: ts(s: 11)),
                  ]),
                ),
            ]),
            Text('كل معركة تكلف نقطة فعل. الزعيم كل 10 مراحل ويسقط بيضاً روحية ونوى وحوش.',
                style: ts(s: 12, c: C.dim)),
          ]);
        },
      ),
    );
  }
}

class _BattlePainter extends CustomPainter {
  final Animation<double> anim;
  final BattleInfo? info;
  final Look look;
  final String weapon;
  final List<Person> mates;
  final String? pet;
  final int stage;
  _BattlePainter(this.anim, this.info, this.look, this.weapon, this.mates, this.pet, this.stage)
      : super(repaint: anim);

  void _text(Canvas c, String s, Offset o, Color col) {
    final tp = TextPainter(
        text: TextSpan(text: s, style: TextStyle(color: col, fontSize: 16, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(c, o);
  }

  void _bar(Canvas c, double x, double y, double w, double v, Color col) {
    final p = Paint();
    c.drawRect(Rect.fromLTWH(x, y, w, 6), p..color = const Color(0xFF000000));
    c.drawRect(Rect.fromLTWH(x + 1, y + 1, (w - 2) * v.clamp(0.0, 1.0), 4), p..color = col);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.height / 60;
    final groundY = size.height - 14 * u;
    final bio = biomes[_stageBiomes[((stage - 1) ~/ 10) % _stageBiomes.length]]!;
    paintBackground(canvas, size, bio, 0, u, groundY, t: anim.value * 10);
    final i = info;
    final t = i == null ? 0.0 : anim.value;
    final win = i?.win ?? true;
    double seg(double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
    final pAtk1 = (t > 0.15 && t < 0.35) ? seg(0.15, 0.35) : -1.0;
    final pAtk2 = (t > 0.45 && t < 0.6) ? seg(0.45, 0.6) : -1.0;
    final pAtk = pAtk1 >= 0 ? pAtk1 : pAtk2;
    final eAtk = (t > 0.62 && t < 0.8) ? seg(0.62, 0.8) : -1.0;
    final lunge = pAtk >= 0 ? sin(pAtk * pi) * u * 12 : 0.0;
    final eLunge = eAtk >= 0 ? sin(eAtk * pi) * u * 10 : 0.0;
    final fy = groundY + 2 * u;
    final px = size.width * 0.28;
    final ex = size.width * 0.74;

    // الفريق خلف اللاعب
    for (int k = 0; k < mates.length; k++) {
      final m = mates[k];
      final mx = px - (14 + k * 13) * u;
      final atk = (t > 0.3 && t < 0.5) ? seg(0.3, 0.5) : -1.0;
      paintHuman(canvas, mx + (atk >= 0 ? sin(atk * pi) * u * 6 : 0), fy + (k.isEven ? 0 : u), u * 0.95, m.look,
          weapon: _mateWeapons[m.talent % 4], atk: atk);
    }
    // الأليف
    if (pet != null) {
      final sp = petSprites[pet!]!;
      paintSprite(canvas, sp, px + 10 * u, fy - sp.h * u * 0.8, u * 0.8);
    }
    // اللاعب
    final playerHit = t > 0.66 && t < 0.78 && eAtk >= 0;
    final lose = !win && t > 0.85;
    paintHuman(canvas, px + lunge, fy, u * 1.05, look,
        weapon: weapon,
        atk: pAtk,
        alpha: lose ? (255 * (1 - seg(0.85, 1.0))).round().clamp(40, 255) : 255,
        flash: playerHit ? 0xFFFFFFFF : null);
    // العدو
    if (i != null) {
      final enemyHit = (t > 0.27 && t < 0.38) || (t > 0.52 && t < 0.62);
      final alpha = win && t > 0.85 ? (255 * (1 - seg(0.85, 1.0))).round() : 255;
      final sc = i.boss ? 1.5 : 1.0;
      final x = ex - eLunge;
      if (i.kind == 'human') {
        paintHuman(canvas, x, fy, u * sc, Look(skin: 1, hair: 5, robe: i.stage % 7),
            dir: -1, weapon: 'sword', atk: eAtk, alpha: alpha, flash: enemyHit ? 0xFFFFFFFF : null,
            robeOverride: i.boss ? 0xFF5A1A1A : null);
      } else {
        final sp = creatureSprites[i.kind] ?? creatureSprites['wolf']!;
        final p2 = u * sc * 0.9;
        paintSprite(canvas, sp, x - sp.w * p2 / 2, fy - sp.h * p2, p2,
            flip: true, alpha: alpha, flash: enemyHit ? 0xFFFFFFFF : null);
      }
      // أشرطة الصحة
      final eHp = win ? 1 - seg(0.2, 0.85) : 1 - 0.5 * seg(0.2, 0.85);
      final pHp = win ? 1 - 0.2 * seg(0.5, 0.85) : 1 - seg(0.5, 0.9);
      _bar(canvas, ex - 20 * u, groundY - 40 * u * sc, 40 * u, eHp, const Color(0xFFE0524E));
      _bar(canvas, px - 15 * u, groundY - 36 * u, 30 * u, pHp, const Color(0xFF5FD3A0));
      // أرقام الضرر
      if (t > 0.3 && t < 0.45) _text(canvas, '-${(i.power * 0.3).round()}', Offset(ex - 8 * u, groundY - 48 * u - seg(0.3, 0.45) * 8 * u), const Color(0xFFFFE08A));
      if (t > 0.65 && t < 0.8) _text(canvas, '-${(i.epower * 0.25).round()}', Offset(px - 6 * u, groundY - 44 * u - seg(0.65, 0.8) * 8 * u), const Color(0xFFFF8A8A));
    }
  }

  @override
  bool shouldRepaint(covariant _BattlePainter old) => true;
}

// ======================= الفريق =======================
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'الفريق',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(10), children: [
          PixelPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('رفاق الرحلة ${g.mates.length}/3', style: ts(s: 16, b: true, c: C.gold)),
              Text('يزيدون قوتك في المعارك. جنّدهم من قرى الفانين بعد كسب ودّهم (20+).',
                  style: ts(s: 12, c: C.dim)),
              StatLine('ودّ الفانين في ${g.here.name}', '${g.goodwill}'),
              StatLine('قوة الفريق المضافة', '${g.teamPower.round()}'),
              PixelButton('جنّد رفيقاً (${g.recruitCost} فضة)', color: C.jade.withAlpha(170),
                  onTap: () => run(context, g.recruit)),
            ]),
          ),
          for (final m in g.mates)
            personCard(
                m,
                [
                  PixelButton('درّبه (${100 * m.skill})', small: true, onTap: () => run(context, () => g.trainMate(m))),
                  PixelButton('ودّعه', small: true, color: C.red.withAlpha(150), onTap: () => run(context, () => g.dismissMate(m))),
                ],
                sub: '${mateClasses[m.talent]} · المستوى ${m.skill} · ${mateDesc[m.talent]}'),
        ]),
      ),
    );
  }
}

// ======================= الأليفة =======================
class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'الحيوانات الأليفة',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(10), children: [
          PixelPanel(
            child: Row(children: [
              const ItemIcon('pet_egg'),
              const SizedBox(width: 8),
              Expanded(child: Text('بيض روحي: ${g.count('pet_egg')}\nيُشترى من العاصمة أو يُهدى من الفانين وزعماء الحملة.',
                  style: ts(s: 12))),
              PixelButton('افقس', small: true, onTap: () => run(context, g.hatchEgg)),
            ]),
          ),
          for (final d in petDefs)
            PixelPanel(
              borderColor: g.activePet?.id == d.id ? C.gold : C.border,
              child: Row(children: [
                Container(
                    width: 60,
                    height: 60,
                    color: C.panel2,
                    child: g.lv('pet_${d.id}') > 0
                        ? SpriteIcon(petSprites[d.id]!, size: 52)
                        : Opacity(opacity: 0.25, child: SpriteIcon(petSprites[d.id]!, size: 52))),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${d.name}${g.lv('pet_${d.id}') > 0 ? ' · المستوى ${g.lv('pet_${d.id}')}' : ' (غير مملوك)'}',
                        style: ts(b: true)),
                    Text(d.desc, style: ts(s: 12, c: C.dim)),
                    Wrap(children: [
                      PixelButton('رافقني', small: true, onTap: () => run(context, () => g.setPet(d))),
                      PixelButton('أطعمه', small: true, onTap: () => run(context, () => g.feedPet(d))),
                    ]),
                  ]),
                ),
              ]),
            ),
          Text('الإطعام: فضة (60 × المستوى) ومؤونتان.', style: ts(s: 12, c: C.dim)),
        ]),
      ),
    );
  }
}

// ======================= المهارات =======================
class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'المهارات والتقنيات',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) {
          final learned = g.learnedSkills;
          final rest = techs.values.where((t) => g.lv('sk_${t.id}') == 0).toList();
          return ListView(padding: const EdgeInsets.all(10), children: [
            PixelPanel(
              child: Text(
                  'مضاعف المهارات القتالية: x${g.skillMul.toStringAsFixed(2)}. تعلّم المهارات من الكتب (الأسواق) أو الطوائف ثم ارفع إتقانها.',
                  style: ts(s: 12, c: C.dim)),
            ),
            const Heading('مهاراتك'),
            if (learned.isEmpty) Text('لم تتعلم مهارة بعد. اشترِ كتاباً من سوق المدينة.', style: ts(c: C.dim)),
            for (final t in learned)
              PixelPanel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(t.name, style: ts(b: true, s: 15))),
                    Tag(techCatName[t.cat] ?? '', color: C.border),
                    Tag('إتقان ${g.lv('sk_${t.id}')}/5', color: C.jade.withAlpha(200)),
                  ]),
                  Text(t.desc, style: ts(s: 12, c: C.dim)),
                  if (!t.passive)
                    PixelButton('ارفع الإتقان (${g.skillCost(t)})', small: true, onTap: () => run(context, () => g.upgradeSkill(t)))
                  else
                    Text('مهارة سلبية: فعّالة بمجرد تعلمها.', style: ts(s: 11, c: C.jade)),
                ]),
              ),
            const Heading('مهارات لم تتعلمها'),
            for (final t in rest)
              PixelPanel(
                color: C.bg,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${t.name} (${techCatName[t.cat]})', style: ts(s: 13, c: C.dim)),
                  Text(t.bookPrice > 0 ? 'كتابها يُباع في الأسواق.' : 'سرّية أو من الطوائف.',
                      style: ts(s: 11, c: C.dim)),
                ]),
              ),
          ]);
        },
      ),
    );
  }
}

// ======================= قائمة وصفات (مشتركة) =======================
class RecipeList extends StatelessWidget {
  final bool pills;
  const RecipeList({super.key, required this.pills});
  @override
  Widget build(BuildContext context) {
    final g = game;
    final list = Game.recipes.entries.where((e) => (item(e.key).kind == IK.pill) == pills).toList();
    return Column(children: [
      for (final e in list)
        PixelPanel(
          child: Row(children: [
            ItemIcon(e.key),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item(e.key).name, style: ts(b: true)),
                if (!pills)
                  Text('هجوم ${item(e.key).atk} · دفاع ${item(e.key).def} · أجر ${g.smithFee(e.key)}',
                      style: ts(s: 11, c: C.dim)),
                Wrap(children: [
                  for (final m in e.value.entries)
                    Text('${item(m.key).name} ${g.count(m.key)}/${m.value}  ',
                        style: ts(s: 11, c: g.count(m.key) >= m.value ? C.jade : C.red)),
                ]),
              ]),
            ),
            PixelButton(pills ? 'اصقل' : 'اطلب', small: true, onTap: () => run(context, () => g.craft(e.key))),
          ]),
        ),
    ]);
  }
}

// ======================= فرن الصقل (للحبوب) =======================
class FurnaceScreen extends StatelessWidget {
  const FurnaceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'فرن صقل الحبوب',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(10), children: [
          PixelPanel(
            borderColor: C.orange,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('فرن الصقل · المستوى ${g.furnaceLv}/10', style: ts(s: 17, b: true, c: C.orange)),
              Text('يرفع نجاح صقل الحبوب (+4% لكل مستوى) ويمنح فرصة مضاعفة الناتج (+5% لكل مستوى). الصيدلي أنجح بـ15%.',
                  style: ts(s: 12, c: C.dim)),
              PixelButton('طوّر الفرن (${g.furnaceCost} فضة)', color: C.orange.withAlpha(180),
                  onTap: () => run(context, g.upgradeFurnace)),
            ]),
          ),
          const Heading('وصفات الحبوب'),
          const RecipeList(pills: true),
        ]),
      ),
    );
  }
}

// ======================= الحداد (أسلحة ودروع) =======================
class SmithScreen extends StatelessWidget {
  const SmithScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'الحداد',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) {
          if (!g.here.market) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('لا حداد في ${g.here.name}. سافر إلى قرية أو مدينة (الحديد الأسود أفضلها).',
                        style: ts(c: C.dim), textAlign: TextAlign.center)));
          }
          return ListView(padding: const EdgeInsets.all(10), children: [
            PixelPanel(
              borderColor: C.gold,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('حدّاد ${g.here.name}', style: ts(s: 17, b: true, c: C.gold)),
                Text('يصنع الأسلحة والدروع ويحسّن سلاحك. الأجر أقل ونسبة النجاح أعلى إن كنت حداداً أو صانع أسلحة، وفي مدينة الحديد الأسود.',
                    style: ts(s: 12, c: C.dim)),
                StatLine('مكافأة النجاح', '+${(g.smithBonus() * 100).round()}%'),
              ]),
            ),
            PixelPanel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('تحسين السلاح', style: ts(s: 16, b: true, c: C.gold)),
                if (g.weapon.isEmpty)
                  Text('جهّز سلاحاً من الحقيبة أولاً.', style: ts(c: C.dim))
                else ...[
                  Text('${item(g.weapon).name} +${g.lv('wplus')}', style: ts(b: true)),
                  StatLine('الهجوم الحالي', '${g.weaponAtk}'),
                  Text(g.lv('wplus') < 4 ? 'يستهلك خام حديد وفضة.' : 'يستهلك حديداً روحياً وفضة. الفشل قد يُنزل المستوى بعد +7.',
                      style: ts(s: 12, c: C.dim)),
                  PixelButton('حسّن السلاح', onTap: () => run(context, g.enhanceWeapon)),
                ],
              ]),
            ),
            const Heading('صناعة الأسلحة والدروع'),
            const RecipeList(pills: false),
          ]);
        },
      ),
    );
  }
}

// ======================= أراضي الفانين =======================
class MortalsScreen extends StatelessWidget {
  const MortalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'أراضي الفانين',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) {
          if (!g.here.market) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('لا فانين في ${g.here.name}. سافر إلى قرية أو مدينة.',
                        style: ts(c: C.dim), textAlign: TextAlign.center)));
          }
          final q = g.mortalRequest();
          return ListView(padding: const EdgeInsets.all(10), children: [
            PixelPanel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.here.name, style: ts(s: 17, b: true, c: C.gold)),
                const SizedBox(height: 4),
                PixelBar(value: g.goodwill / 100, color: C.jade, label: 'ودّ الفانين ${g.goodwill}/100'),
                Text('كلما ساعدتهم ارتفع ودّهم: 15 لطلب الموارد، 20 لتجنيد الرفاق، 50 لهدية خاصة.',
                    style: ts(s: 12, c: C.dim)),
              ]),
            ),
            PixelPanel(
              borderColor: g.mortalDone ? C.border : C.gold,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('طلب هذا الشهر', style: ts(b: true, c: C.gold)),
                Text(g.mortalDone ? 'ساعدتهم هذا الشهر. شكراً لك!' : q['text'] as String, style: ts(s: 14)),
                if (!g.mortalDone) Text('المكافأة: ${q['reward']} فضة + ودّ', style: ts(s: 12, c: C.jade)),
                Wrap(children: [
                  PixelButton('ساعدهم', color: C.jade.withAlpha(170),
                      onTap: g.mortalDone ? null : () => run(context, g.mortalHelp)),
                  PixelButton('تجاهل', small: true, onTap: () => toast(context, 'مضيت في طريقك. المساعدة اختيارية.')),
                ]),
              ]),
            ),
            PixelPanel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('اطلب موارد ونباتات', style: ts(b: true)),
                Text('يمنحك الفانون أعشاب أرضهم ومؤونة مقابل 15 ودّاً.', style: ts(s: 12, c: C.dim)),
                PixelButton('اطلب الموارد', onTap: () => run(context, g.mortalAsk)),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}

// ======================= المكافأة اليومية =======================
class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    return GameScaffold(
      title: 'المكافأة اليومية',
      body: ListenableBuilder(
        listenable: g,
        builder: (context, _) {
          final cur = g.dailyReady ? g.dailyDay : g.lv('ds');
          return ListView(padding: const EdgeInsets.all(10), children: [
            Text('سجّل دخولك كل يوم للحصول على مكافأة. تنقطع السلسلة بتفويت يوم.', style: ts(s: 12, c: C.dim)),
            const SizedBox(height: 8),
            Wrap(children: [
              for (int i = 0; i < 7; i++)
                Container(
                  width: 82,
                  height: 84,
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: i + 1 < cur || (i + 1 == cur && !g.dailyReady) ? const Color(0xFF244A3A) : C.panel,
                    border: Border.all(color: i + 1 == cur ? C.gold : C.border, width: 3),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('اليوم ${i + 1}', style: ts(s: 12, b: true, c: C.gold)),
                    Text(dailyNames[i], style: ts(s: 11), textAlign: TextAlign.center),
                    if (i + 1 < cur || (i + 1 == cur && !g.dailyReady)) const Icon(Icons.check, color: C.jade, size: 16),
                  ]),
                ),
            ]),
            PixelButton(g.dailyReady ? 'استلم مكافأة اليوم' : 'تم الاستلام', color: C.jade.withAlpha(170),
                onTap: g.dailyReady ? () => run(context, g.claimDaily) : null),
          ]);
        },
      ),
    );
  }
}
