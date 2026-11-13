import 'package:flutter/material.dart';
import '../core/pixel.dart';
import '../core/sprites.dart';
import '../core/theme.dart';
import '../data/cultivation.dart';
import '../data/events.dart';
import '../data/items.dart';
import '../data/world.dart';
import '../game/game.dart';
import 'common.dart';
import 'extras_ui.dart';
import 'more.dart';
import '../game/extras.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || game.dead || !game.dailyReady) return;
      showDialog(
          context: context,
          builder: (ctx) => Directionality(
                textDirection: TextDirection.rtl,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  child: PixelPanel(
                    borderColor: C.gold,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('مكافأة يومية!', style: ts(s: 18, b: true, c: C.gold)),
                      const SizedBox(height: 6),
                      Text('مرحباً بعودتك. اليوم ${game.dailyDay} من 7.', style: ts()),
                      PixelButton('استلم', color: C.jade.withAlpha(170), onTap: () {
                        final r = game.claimDaily();
                        game.changed();
                        Navigator.pop(ctx);
                        toast(context, r);
                      }),
                      PixelButton('لاحقاً', small: true, onTap: () => Navigator.pop(ctx)),
                    ]),
                  ),
                ),
              ));
    });
  }

  void _check() {
    if (!mounted || _busy) return;
    if (game.pending != null) {
      _busy = true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const EventDialog()).then((_) {
        _busy = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      });
    } else if (game.dead) {
      _busy = true;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const DeathScreen()))
          .then((r) {
        _busy = false;
        if (r == 'menu') {
          Navigator.of(context).pop();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) => _check());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _check());
        final tabs = <Widget>[
          const HomeTab(),
          const ActionsTab(),
          const FamilyTab(),
          const BagTab(),
          const MoreTab(),
        ];
        return GameScaffold(
          back: false,
          title: game.name,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Text('💰 ${fmt0(game.silver)}', style: ts(c: C.gold, b: true))),
            ),
          ],
          body: Column(children: [
            Expanded(child: tabs[tab]),
            Container(
              decoration: const BoxDecoration(
                  color: C.panel, border: Border(top: BorderSide(color: C.border, width: 3))),
              child: Row(children: [
                _nav(0, Icons.home, 'الرئيسية'),
                _nav(1, Icons.self_improvement, 'الأنشطة'),
                _nav(2, Icons.family_restroom, 'العائلة'),
                _nav(3, Icons.backpack, 'الحقيبة'),
                _nav(4, Icons.menu, 'المزيد'),
              ]),
            ),
          ]),
        );
      },
    );
  }

  Widget _nav(int i, IconData ic, String label) {
    final sel = tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          tap();
          setState(() => tab = i);
        },
        child: Container(
          color: sel ? C.panel2 : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(ic, color: sel ? C.gold : C.dim, size: 22),
            Text(label, style: ts(s: 11, c: sel ? C.gold : C.dim, b: sel)),
          ]),
        ),
      ),
    );
  }
}

String fmt0(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return (n < 0 ? '-' : '') + b.toString();
}

// ---------------- نافذة الحدث ----------------
class EventDialog extends StatefulWidget {
  const EventDialog({super.key});
  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late final Ev ev;
  String? result;
  @override
  void initState() {
    super.initState();
    ev = game.pending!;
  }

  @override
  Widget build(BuildContext context) {
    final sp = itemSprites2(ev.icon);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(14),
        child: PixelPanel(
          borderColor: C.gold,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                SpriteIcon(sp, size: 28, tint: 0xFFE8C766),
                const SizedBox(width: 8),
                Expanded(child: Text(ev.title, style: ts(s: 18, b: true, c: C.gold))),
              ]),
              const SizedBox(height: 8),
              Text(ev.text, style: ts(s: 15)),
              const SizedBox(height: 10),
              if (result == null)
                for (int i = 0; i < ev.ch.length; i++)
                  SizedBox(
                      width: double.infinity,
                      child: PixelButton(ev.ch[i].t, onTap: () {
                        final r = game.chooseEvent(i);
                        setState(() => result = r.isEmpty ? 'مضى الأمر.' : r);
                      }))
              else ...[
                PixelPanel(color: C.panel2, child: Text(result!, style: ts(s: 14, c: C.jade))),
                SizedBox(
                    width: double.infinity,
                    child: PixelButton('متابعة', onTap: () => Navigator.pop(context))),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

Sprite itemSprites2(String k) => itemSprites[k] ?? itemSprites['scroll']!;

// ---------------- الرئيسية ----------------
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    final w = g.weapon.isEmpty ? 'none' : item(g.weapon).wtype;
    return ListView(padding: const EdgeInsets.all(10), children: [
      PixelPanel(
        padding: EdgeInsets.zero,
        child: Column(children: [
          SceneView(biome: g.here.biome, look: g.look, weapon: w, height: 150),
          Container(
            color: C.panel2,
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                  child: Text('${g.here.name}\n${g.dateStr}', style: ts(s: 13, b: true))),
              Tag('جيل ${g.generation}', color: C.purple),
              Tag(realms[g.realm].name, color: C.jade.withAlpha(200)),
            ]),
          ),
        ]),
      ),
      PixelPanel(
        child: Column(children: [
          PixelBar(value: g.health / g.maxHealth, color: C.red, label: 'الصحة ${g.health}/${g.maxHealth}'),
          const SizedBox(height: 4),
          PixelBar(value: g.mood / 100, color: C.orange, label: 'المزاج ${g.mood}'),
          const SizedBox(height: 4),
          PixelBar(
              value: (g.age - 16) / (g.lifespan - 16 + 0.0),
              color: C.blue,
              label: 'العمر ${g.age} / ${g.lifespan} (${ageStage(g.age, g.lifespan)})'),
          const SizedBox(height: 6),
          Row(children: [
            Text('نقاط الفعل: ', style: ts(c: C.dim)),
            for (int i = 0; i < g.maxAp; i++)
              Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(left: 4),
                  color: i < g.ap ? C.gold : const Color(0xFF3A3550)),
            const Spacer(),
            Text('المهنة: ${jobOf(g.job).name}', style: ts(s: 12, c: C.dim)),
          ]),
        ]),
      ),
      SizedBox(
        width: double.infinity,
        child: PixelButton('⏭  الشهر التالي', color: C.jade.withAlpha(180), onTap: () {
          game.nextMonth();
        }),
      ),
      const Heading('سجل الأحداث'),
      for (final l in g.log.take(8))
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(l, style: ts(s: 12, c: C.dim))),
    ]);
  }
}

// ---------------- الأنشطة والزراعة ----------------
class ActionsTab extends StatelessWidget {
  const ActionsTab({super.key});

  Widget _act(BuildContext c, String label, String Function() f, {IconData? ic}) =>
      PixelButton(label, icon: ic, small: true, onTap: () => run(c, f));

  @override
  Widget build(BuildContext context) {
    final g = game;
    final r = realms[g.realm];
    final need = xpNeed(g.realm, g.sub);
    final ready = g.sub >= r.subs && g.xp >= need && g.realm < 8;
    return ListView(padding: const EdgeInsets.all(10), children: [
      PixelPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${r.name} · ${subName(g.realm, g.sub)}', style: ts(s: 17, b: true, c: C.jade)),
          Text(r.desc, style: ts(s: 12, c: C.dim)),
          const SizedBox(height: 6),
          PixelBar(
              value: g.realm >= 8 && g.sub >= 3 ? 1 : g.xp / need,
              color: C.purple,
              label: 'الخبرة ${fmt0(g.xp.round())} / ${fmt0(need.round())}'),
          const SizedBox(height: 6),
          StatLine('الجذر الروحي',
              g.realm >= 1 ? '${rootNames[g.rootEl]} (${purityNames[g.purity]})' : 'غير مكتشف'),
          StatLine('كثافة الطاقة هنا', g.here.density.toStringAsFixed(1)),
          StatLine('مضاعف التدريب', 'x${g.cultMul.toStringAsFixed(2)}'),
          StatLine('سمّية الحبوب', '${g.toxin}', color: g.toxin > 50 ? C.red : C.text),
          StatLine('القوة القتالية', fmt0(g.power.round())),
          if (g.sub >= r.subs && g.realm < 8) ...[
            const Divider(color: C.border),
            Text('متطلبات الاختراق:', style: ts(b: true, c: C.gold, s: 13)),
            for (final e in r.need.entries)
              StatLine(item(e.key).name, '${g.count(e.key)}/${e.value}',
                  color: g.count(e.key) >= e.value ? C.jade : C.red),
            StatLine('احتمال النجاح', '${(g.btChance() * 100).round()}%'),
            if (g.realm == 7)
              StatLine('سرّ البوابة الفارغة', g.knows('void_gate_path') ? 'معروف' : 'مجهول',
                  color: g.knows('void_gate_path') ? C.jade : C.red),
            PixelButton('حاول الاختراق', color: ready ? C.orange.withAlpha(200) : C.border,
                onTap: () => run(context, g.breakthrough)),
          ],
        ]),
      ),
      const Heading('تدريب وحياة'),
      Wrap(children: [
        _act(context, 'تأمل', g.meditate, ic: Icons.self_improvement),
        _act(context, 'تدريب الجسد', g.trainBody, ic: Icons.fitness_center),
        _act(context, 'دراسة', g.study, ic: Icons.menu_book),
        _act(context, 'تواصل اجتماعي', g.socialize, ic: Icons.people),
        _act(context, 'عمل إضافي', g.workExtra, ic: Icons.work),
        _act(context, 'راحة', g.rest, ic: Icons.bed),
      ]),
      const Heading('الاستكشاف والصيد'),
      Wrap(children: [
        _act(context, 'جمع أعشاب', g.gather, ic: Icons.grass),
        _act(context, 'صيد وحوش', g.hunt, ic: Icons.pest_control),
        _act(context, 'استكشاف', g.explore, ic: Icons.explore),
        _act(context, 'حفر كنز', g.digTreasure, ic: Icons.map),
      ]),
      Heading('مواقع في ${g.here.name}'),
      if (sitesIn(g.regionId).where((s) => !s.hidden || g.knows('lotus') || g.found.contains(s.region)).isEmpty)
        Text('لا مواقع هنا.', style: ts(c: C.dim)),
      for (final s in sitesIn(g.regionId))
        PixelPanel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(s.name, style: ts(b: true, s: 15))),
              if (s.lethal) const Tag('خطر مميت', color: C.red),
              Tag('مستوى ${s.level}', color: C.border),
            ]),
            Text(s.desc, style: ts(s: 12, c: C.dim)),
            Text(
                s.minRealm > 0 ? 'يتطلب: ${realms[s.minRealm].name}' : 'مفتوح للجميع',
                style: ts(s: 12, c: g.realm >= s.minRealm ? C.jade : C.red)),
            if ((g.siteCd[s.id] ?? 0) > 0)
              Text('يعود بعد ${g.siteCd[s.id]} أشهر', style: ts(s: 12, c: C.orange)),
            PixelButton('اقتحم', small: true, color: C.red.withAlpha(150),
                onTap: () => run(context, () => g.exploreSite(s))),
          ]),
        ),
    ]);
  }
}

// ---------------- العائلة ----------------
class FamilyTab extends StatelessWidget {
  const FamilyTab({super.key});
  @override
  Widget build(BuildContext context) {
    final g = game;
    final alive = g.people.where((p) => p.alive).toList();
    List<Person> of(String r) => alive.where((p) => p.role == r).toList();
    final parents = [...of('father'), ...of('mother')];
    final sp = of('spouse');
    final kids = of('child');
    final sibs = of('sibling');
    final cands = of('candidate');
    return ListView(padding: const EdgeInsets.all(10), children: [
      PixelButton('التعرف على أشخاص جدد (فعل)', icon: Icons.person_add,
          onTap: () => run(context, g.socialize)),
      if (sp.isNotEmpty) ...[
        const Heading('شريك الحياة'),
        for (final p in sp)
          personCard(p, [
            PixelButton('حديث (فعل)', small: true, onTap: () => run(context, () => g.chat(p))),
            PixelButton('هدية 50', small: true, onTap: () => run(context, () => g.gift(p))),
          ]),
      ],
      if (kids.isNotEmpty) ...[
        const Heading('الأبناء'),
        for (final p in kids)
          personCard(
              p,
              [
                PixelButton('تعليم قتال', small: true, onTap: () => run(context, () => g.teachChild(p, 'قتال'))),
                PixelButton('تعليم علوم', small: true, onTap: () => run(context, () => g.teachChild(p, 'علوم'))),
                PixelButton('هدية 50', small: true, onTap: () => run(context, () => g.gift(p))),
              ],
              sub: 'الموهبة ${p.talent}/10 · المهارة ${p.skill}${p.age >= 16 ? ' · بالغ (وريث محتمل)' : ''}'),
      ],
      const Heading('الأهل'),
      if (parents.isEmpty) Text('رحل والداك.', style: ts(c: C.dim)),
      for (final p in parents)
        personCard(p, [
          PixelButton('حديث (فعل)', small: true, onTap: () => run(context, () => g.chat(p))),
          PixelButton('هدية 50', small: true, onTap: () => run(context, () => g.gift(p))),
        ]),
      if (sibs.isNotEmpty) ...[
        const Heading('الإخوة'),
        for (final p in sibs) personCard(p, []),
      ],
      Heading(sp.isEmpty ? 'المعارف (للزواج)' : 'معارف'),
      if (cands.isEmpty) Text('لا معارف بعد. استخدم «التعرف».', style: ts(c: C.dim)),
      for (final p in cands)
        personCard(p, [
          PixelButton('حديث (فعل)', small: true, onTap: () => run(context, () => g.chat(p))),
          PixelButton('هدية 50', small: true, onTap: () => run(context, () => g.gift(p))),
          if (sp.isEmpty)
            PixelButton('اطلب الزواج (300)', small: true, color: C.red.withAlpha(170),
                onTap: () => run(context, () => g.propose(p))),
        ], sub: 'الموهبة ${p.talent}/10'),
    ]);
  }
}

// ---------------- الحقيبة / المتجر / الصناعة / المهنة / البيت ----------------
class BagTab extends StatelessWidget {
  const BagTab({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(children: [
        Container(
          color: C.panel2,
          child: TabBar(
            isScrollable: true,
            labelColor: C.gold,
            unselectedLabelColor: C.dim,
            indicatorColor: C.gold,
            tabs: const [
              Tab(text: 'الحقيبة'),
              Tab(text: 'المتجر'),
              Tab(text: 'الحبوب'),
              Tab(text: 'المهنة'),
              Tab(text: 'البيت'),
            ],
          ),
        ),
        const Expanded(
          child: TabBarView(children: [
            _Inventory(),
            _Shop(),
            _Craft(),
            _Jobs(),
            _Homes(),
          ]),
        ),
      ]),
    );
  }
}

class _Inventory extends StatelessWidget {
  const _Inventory();
  @override
  Widget build(BuildContext context) {
    final g = game;
    final ids = g.inv.keys.toList()..sort((a, b) => item(a).kind.index.compareTo(item(b).kind.index));
    return ListView(padding: const EdgeInsets.all(10), children: [
      PixelPanel(
        child: Column(children: [
          StatLine('السلاح', g.weapon.isEmpty ? 'لا شيء' : '${item(g.weapon).name} (+${item(g.weapon).atk})'),
          StatLine('الدرع', g.armor.isEmpty ? 'لا شيء' : '${item(g.armor).name} (+${item(g.armor).def})'),
          StatLine('القوة / الحكمة / السحر / الحظ', '${g.str} / ${g.wis} / ${g.cha} / ${g.luck}'),
        ]),
      ),
      if (ids.isEmpty) Text('الحقيبة فارغة.', style: ts(c: C.dim)),
      for (final id in ids) _row(context, id),
    ]);
  }

  Widget _row(BuildContext context, String id) {
    final it = item(id);
    final g = game;
    final canUse = it.fx.isNotEmpty || it.kind == IK.book || id == 'pet_egg';
    return PixelPanel(
      child: Row(children: [
        ItemIcon(id),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${it.name} × ${g.count(id)}', style: ts(b: true)),
            Text(
                '${ikName[it.kind]} · ${tierNames[it.tier.clamp(0, 5)]}${it.atk > 0 ? ' · هجوم ${it.atk}' : ''}${it.def > 0 ? ' · دفاع ${it.def}' : ''}',
                style: ts(s: 11, c: C.dim)),
            if (it.desc.isNotEmpty) Text(it.desc, style: ts(s: 11, c: C.dim)),
            Wrap(children: [
              if (canUse)
                PixelButton(id == 'pet_egg' ? 'افقس' : 'استخدم', small: true,
                    onTap: () => run(context, () => id == 'pet_egg' ? g.hatchEgg() : g.useItem(id))),
              if (it.kind == IK.weapon || it.kind == IK.armor)
                PixelButton('جهّز', small: true, onTap: () => run(context, () => g.equip(id))),
              if (it.tradable && it.price > 0 && g.here.market)
                PixelButton('بيع ${g.sellPrice(id)}', small: true, color: C.orange.withAlpha(170),
                    onTap: () => run(context, () => g.sell(id))),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Shop extends StatelessWidget {
  const _Shop();
  @override
  Widget build(BuildContext context) {
    final g = game;
    if (!g.here.market) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('لا سوق في ${g.here.name}. سافر إلى مدينة أو قرية.',
                  style: ts(c: C.dim), textAlign: TextAlign.center)));
    }
    return ListView(padding: const EdgeInsets.all(10), children: [
      Text('سوق ${g.here.name}', style: ts(s: 16, b: true, c: C.gold)),
      for (final id in g.here.sells)
        PixelPanel(
          child: Row(children: [
            ItemIcon(id),
            const SizedBox(width: 8),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item(id).name, style: ts(b: true)),
              Text(item(id).desc, style: ts(s: 11, c: C.dim)),
            ])),
            PixelButton('${g.buyPrice(id)} 💰', small: true,
                color: g.silver >= g.buyPrice(id) ? C.jade.withAlpha(170) : C.border,
                onTap: () => run(context, () => g.buy(id))),
          ]),
        ),
    ]);
  }
}

class _Craft extends StatelessWidget {
  const _Craft();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(10), children: [
      Text('صقل الحبوب يستهلك نقطة فعل (طوّر الفرن من «المزيد › فرن الصقل»). الأسلحة والدروع عند «الحداد».',
          style: ts(s: 12, c: C.dim)),
      const RecipeList(pills: true),
    ]);
  }
}

class _Jobs extends StatelessWidget {
  const _Jobs();
  @override
  Widget build(BuildContext context) {
    final g = game;
    return ListView(padding: const EdgeInsets.all(10), children: [
      for (final j in jobs.skip(1))
        PixelPanel(
          borderColor: g.job == j.id ? C.gold : C.border,
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${j.name} · ${j.salary} فضة/شهر', style: ts(b: true)),
                Text(j.desc, style: ts(s: 12, c: C.dim)),
                Text('يتطلب ${Game.statName(j.stat)} ${j.needStat}', style: ts(s: 11, c: C.dim)),
              ]),
            ),
            PixelButton(g.job == j.id ? 'حالياً' : 'اعمل', small: true,
                onTap: g.job == j.id ? null : () => run(context, () => g.takeJob(j.id))),
          ]),
        ),
      if (g.job != 'none')
        PixelButton('اترك العمل', small: true, color: C.red.withAlpha(150), onTap: () {
          g.job = 'none';
          g.changed();
        }),
    ]);
  }
}

class _Homes extends StatelessWidget {
  const _Homes();
  @override
  Widget build(BuildContext context) {
    final g = game;
    return ListView(padding: const EdgeInsets.all(10), children: [
      for (final h in homes)
        PixelPanel(
          borderColor: g.home == h.id ? C.gold : C.border,
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(h.name, style: ts(b: true, s: 15)),
                Text('الشفاء +${h.heal} · التدريب x${h.cult} · الصيانة ${h.upkeep}/شهر',
                    style: ts(s: 12, c: C.dim)),
              ]),
            ),
            PixelButton(g.home == h.id ? 'تسكنه' : '${fmt0(h.price)} 💰', small: true,
                onTap: g.home == h.id ? null : () => run(context, () => g.buyHome(h))),
          ]),
        ),
    ]);
  }
}
