import 'techniques.dart';

enum IK { herb, material, pill, weapon, armor, talisman, book, food, misc, relic }

const Map<IK, String> ikName = {
  IK.herb: 'عشبة',
  IK.material: 'مادة',
  IK.pill: 'حبة',
  IK.weapon: 'سلاح',
  IK.armor: 'درع',
  IK.talisman: 'تميمة',
  IK.book: 'كتاب',
  IK.food: 'طعام',
  IK.misc: 'متفرقات',
  IK.relic: 'أثر',
};

class ItemDef {
  final String id, name, desc;
  final IK kind;
  final int price, tier;
  final String icon; // مفتاح في itemSprites
  final String wtype; // sword spear dagger bow staff
  final int atk, def, hp, qi, agi, luck;
  final String tech; // كتاب
  final Map<String, int> fx; // تأثيرات الحبوب
  final bool tradable;
  const ItemDef(this.id, this.name, this.kind, this.price,
      {this.tier = 0,
      this.desc = '',
      this.icon = 'gem',
      this.wtype = '',
      this.atk = 0,
      this.def = 0,
      this.hp = 0,
      this.qi = 0,
      this.agi = 0,
      this.luck = 0,
      this.tech = '',
      this.fx = const {},
      this.tradable = true});

  bool get isGear =>
      kind == IK.weapon || kind == IK.armor || kind == IK.talisman;
}

const List<int> tierColors = [
  0xFFB8C0D0,
  0xFF5FD3A0,
  0xFF58B0FF,
  0xFFB07CFF,
  0xFFE8C766,
  0xFFFF7A4D
];
const List<String> tierNames = ['عادي', 'جيد', 'نادر', 'ملحمي', 'أسطوري', 'سماوي'];

const List<String> weaponTypes = ['sword', 'spear', 'dagger', 'bow', 'staff'];
const Map<String, String> weaponNames = {
  'sword': 'سيف',
  'spear': 'رمح',
  'dagger': 'خنجر',
  'bow': 'قوس',
  'staff': 'عصا روحية',
  'none': 'بلا سلاح',
};
const Map<String, int> weaponBase = {
  'sword': 10,
  'spear': 9,
  'dagger': 7,
  'bow': 8,
  'staff': 7,
};
const List<String> tierAdj = ['حديدي', 'فولاذي', 'روحي', 'سماوي'];
const List<double> tierMul = [1.0, 1.8, 3.0, 4.8];
const List<int> weaponPrice = [70, 340, 2000, 14000];

final Map<String, ItemDef> items = _build();

Map<String, ItemDef> _build() {
  final m = <String, ItemDef>{};
  void a(ItemDef d) => m[d.id] = d;

  // أعشاب
  a(const ItemDef('qi_grass', 'عشبة الطاقة', IK.herb, 12,
      icon: 'herb', desc: 'عشبة شائعة غنية بالطاقة الروحية الخفيفة.'));
  a(const ItemDef('frostmint', 'نعناع الصقيع', IK.herb, 16,
      icon: 'herb', desc: 'تبرّد الحمّى وتُستخدم ضد الأوبئة.'));
  a(const ItemDef('fire_berry', 'توت اللهب', IK.herb, 20,
      icon: 'herb', desc: 'ثمرة حارة تُسخّن الجسد وتقوّي العظام.'));
  a(const ItemDef('jade_moss', 'طحلب اليشم', IK.herb, 30,
      icon: 'herb', desc: 'يمتص السموم من الجسد.'));
  a(const ItemDef('blood_ginseng', 'جنسنغ الدم', IK.herb, 55,
      tier: 1, icon: 'herb', desc: 'جذر أحمر يعزز الدم والحيوية.'));
  a(const ItemDef('ghost_orchid', 'سحلب الأشباح', IK.herb, 210,
      tier: 2, icon: 'herb', desc: 'تنمو في المستنقعات المسكونة. تطيل العمر.'));
  a(const ItemDef('moon_lotus', 'لوتس القمر', IK.herb, 130,
      tier: 2, icon: 'herb', desc: 'زهرة لا تتفتح إلا ليلاً. أساس حبوب التأسيس.'));
  a(const ItemDef('soul_flower', 'زهرة الروح', IK.herb, 900,
      tier: 3, icon: 'herb', desc: 'نبتة نادرة تغذي الروح.'));
  a(const ItemDef('dawn_lotus', 'لوتس الفجر', IK.herb, 3000,
      tier: 4,
      icon: 'herb',
      tradable: false,
      desc: 'كنز لا يظهر إلا مرة في العمر عند الفجر. يفتح أبواب الخلود.'));
  // مواد
  a(const ItemDef('cloth', 'قماش', IK.material, 6, icon: 'pelt'));
  a(const ItemDef('wolf_pelt', 'جلد ذئب', IK.material, 14, icon: 'pelt'));
  a(const ItemDef('boar_tusk', 'ناب خنزير', IK.material, 11, icon: 'bone'));
  a(const ItemDef('bone_shard', 'شظية عظم', IK.material, 8, icon: 'bone'));
  a(const ItemDef('ghost_dust', 'غبار الأشباح', IK.material, 45, tier: 1, icon: 'gem'));
  a(const ItemDef('shadow_essence', 'جوهر الظل', IK.material, 130, tier: 2, icon: 'gem'));
  a(const ItemDef('spirit_fang', 'ناب الذئب الروحي', IK.material, 95, tier: 1, icon: 'bone'));
  a(const ItemDef('ancient_gear', 'ترس قديم', IK.material, 160, tier: 2, icon: 'ore'));
  a(const ItemDef('beast_core_1', 'نواة وحش ضعيفة', IK.material, 65, tier: 1, icon: 'gem'));
  a(const ItemDef('beast_core_2', 'نواة وحش متوسطة', IK.material, 320, tier: 2, icon: 'gem'));
  a(const ItemDef('beast_core_3', 'نواة وحش قوية', IK.material, 1600, tier: 3, icon: 'gem'));
  a(const ItemDef('iron_ore', 'خام الحديد', IK.material, 10, icon: 'ore'));
  a(const ItemDef('spirit_iron', 'حديد روحي', IK.material, 85, tier: 2, icon: 'ore'));
  a(const ItemDef('cold_jade', 'يشم بارد', IK.material, 260, tier: 3, icon: 'gem'));
  a(const ItemDef('star_silver', 'فضة نجمية', IK.material, 420, tier: 3, icon: 'ore'));
  // طعام
  a(const ItemDef('ration', 'مؤونة', IK.food, 4,
      icon: 'food', desc: 'طعام يومي أساسي.', fx: {'heal': 6}));
  a(const ItemDef('roast_meat', 'لحم مشوي', IK.food, 10,
      icon: 'food', desc: 'يستعيد الصحة.', fx: {'heal': 40}));
  a(const ItemDef('spirit_rice', 'أرز روحي', IK.food, 45,
      tier: 1, icon: 'food', desc: 'يمنح طاقة روحية.', fx: {'heal': 30, 'qi': 40}));
  // حبوب
  a(const ItemDef('heal_pill', 'حبة الشفاء', IK.pill, 40,
      icon: 'pill', desc: 'تعيد 45% من الصحة.', fx: {'healPct': 45}));
  a(const ItemDef('qi_pill', 'حبة جمع الطاقة', IK.pill, 55,
      icon: 'pill', desc: 'تضيف تقدماً في التدريب.', fx: {'xpPct': 30, 'tox': 6}));
  a(const ItemDef('body_pill', 'حبة صقل الجسد', IK.pill, 90,
      tier: 1, icon: 'pill', desc: 'تقوّي الجسد.', fx: {'body': 3, 'tox': 8}));
  a(const ItemDef('antidote_pill', 'حبة الترياق', IK.pill, 60,
      icon: 'pill', desc: 'تعالج الأمراض والأوبئة.', fx: {'cure': 1}));
  a(const ItemDef('detox_pill', 'حبة التنقية', IK.pill, 80,
      tier: 1, icon: 'pill', desc: 'تخفض السمّية المتراكمة.', fx: {'detox': 40}));
  a(const ItemDef('foundation_pill', 'حبة التأسيس', IK.pill, 700,
      tier: 2, icon: 'pill', desc: 'ترفع نجاح اختراق مرحلة التأسيس.', fx: {'bt2': 30, 'tox': 15}));
  a(const ItemDef('core_pill', 'حبة النواة', IK.pill, 4000,
      tier: 3, icon: 'pill', desc: 'ترفع نجاح تكوين النواة.', fx: {'bt3': 30, 'tox': 20}));
  a(const ItemDef('nascent_pill', 'حبة الروح الوليدة', IK.pill, 22000,
      tier: 4, icon: 'pill', desc: 'ترفع نجاح ولادة الروح.', fx: {'bt4': 30, 'tox': 25}));
  a(const ItemDef('longevity_pill', 'حبة العمر المديد', IK.pill, 1800,
      tier: 3, icon: 'pill', desc: 'تزيد العمر 4 سنوات. سمّية عالية.', fx: {'life': 4, 'tox': 30}));
  a(const ItemDef('big_xp_pill', 'حبة التجلّي', IK.pill, 1500,
      tier: 3, icon: 'pill', desc: 'تقدّم هائل في التدريب.', fx: {'xpPct': 120, 'tox': 28}));
  // متفرقات
  a(const ItemDef('treasure_map', 'خريطة كنز', IK.misc, 150,
      icon: 'scroll', desc: 'تشير إلى موقع كنز قريب. تُستخدم عند الحفر.'));
  a(const ItemDef('ancient_codex', 'مخطوطة قديمة', IK.misc, 400,
      tier: 2, icon: 'scroll', desc: 'تحتوي معرفة منسية. قد تكشف تقنية.'));
  a(const ItemDef('heaven_ledger', 'الدفتر السماوي', IK.misc, 0,
      tier: 4,
      icon: 'book',
      tradable: false,
      desc: 'سجل غامض يفكّ شيفرة حدود الزراعة الروحية.'));
  a(const ItemDef('forged_letter', 'رسالة مزوّرة', IK.misc, 0,
      tier: 2,
      icon: 'scroll',
      tradable: false,
      desc: 'دليل على مؤامرة تشعل الحرب بين الطائفتين.'));
  a(const ItemDef('sect_token', 'رمز الطائفة', IK.misc, 0,
      tier: 1, icon: 'talisman', tradable: false, desc: 'يثبت انتماءك.'));
  a(const ItemDef('fate_shard', 'شظية القدر', IK.relic, 0,
      tier: 5,
      icon: 'gem',
      tradable: false,
      desc: 'شظية من مرآة الأقدار. تُبقي ذكرى حيواتك.'));

  // أدوات وحيوانات
  a(const ItemDef('herb_basket', 'سلة الأعشاب', IK.misc, 300,
      tier: 1, icon: 'herb', desc: 'أداة: تجمع +2 أعشاب في كل عملية جمع.'));
  a(const ItemDef('iron_pickaxe', 'معول حديدي', IK.misc, 350,
      tier: 1, icon: 'ore', desc: 'أداة: يستخرج خام الحديد عند جمع الموارد.'));
  a(const ItemDef('spirit_gourd', 'قرعة جمع الروح', IK.misc, 1200,
      tier: 2, icon: 'gem', desc: 'أداة: +8% سرعة التدريب الروحي.'));
  a(const ItemDef('pet_egg', 'بيضة روحية', IK.misc, 900,
      tier: 2, icon: 'gem', desc: 'تفقس عن حيوان أليف يرافقك. استخدمها من شاشة الحيوانات.'));
  // أسلحة
  for (final t in weaponTypes) {
    for (int i = 0; i < 4; i++) {
      final atk = (weaponBase[t]! * tierMul[i]).round();
      m['${t}_$i'] = ItemDef('${t}_$i', '${weaponNames[t]} ${tierAdj[i]}',
          IK.weapon, weaponPrice[i],
          tier: i,
          icon: t,
          wtype: t,
          atk: atk,
          qi: t == 'staff' ? 15 * (i + 1) : 0,
          tradable: i < 3,
          desc: 'سلاح من نوع ${weaponNames[t]}.');
    }
  }
  a(const ItemDef('moonsever', 'سيف قاطع القمر', IK.weapon, 0,
      tier: 4, icon: 'sword', wtype: 'sword', atk: 62, agi: 4, tradable: false,
      desc: 'سيف أسطوري يقطع ضوء القمر نفسه.'));
  a(const ItemDef('dragonbone', 'رمح عظم التنين', IK.weapon, 0,
      tier: 4, icon: 'spear', wtype: 'spear', atk: 56, hp: 40, tradable: false,
      desc: 'نُحت من عمود تنين قديم.'));
  a(const ItemDef('whisperfang', 'خنجر ناب الهمس', IK.weapon, 0,
      tier: 4, icon: 'dagger', wtype: 'dagger', atk: 44, agi: 8, luck: 4, tradable: false,
      desc: 'لا يُسمع له صوت عند الطعن.'));
  a(const ItemDef('heavenpierce', 'قوس ثاقب السماء', IK.weapon, 0,
      tier: 4, icon: 'bow', wtype: 'bow', atk: 52, tradable: false,
      desc: 'سهامه تخترق الغيوم.'));
  a(const ItemDef('ninefold', 'عصا الأرواح التسع', IK.weapon, 0,
      tier: 4, icon: 'staff', wtype: 'staff', atk: 48, qi: 90, tradable: false,
      desc: 'تسكنها تسع أرواح قديمة.'));
  // دروع
  a(const ItemDef('cloth_robe', 'ثوب قماشي', IK.armor, 45,
      icon: 'armor', def: 2, desc: 'ثوب بسيط.'));
  a(const ItemDef('leather_armor', 'درع جلدي', IK.armor, 140,
      tier: 1, icon: 'armor', def: 5, agi: 1));
  a(const ItemDef('iron_plate', 'درع حديدي', IK.armor, 480,
      tier: 1, icon: 'armor', def: 10, agi: -1));
  a(const ItemDef('spirit_robe', 'رداء روحي', IK.armor, 2400,
      tier: 2, icon: 'armor', def: 16, qi: 25));
  a(const ItemDef('dragon_scale', 'درع حراشف التنين', IK.armor, 0,
      tier: 4, icon: 'armor', def: 30, hp: 70, tradable: false));
  // تمائم
  a(const ItemDef('jade_pendant', 'قلادة اليشم', IK.talisman, 220,
      tier: 1, icon: 'talisman', hp: 35));
  a(const ItemDef('wind_charm', 'تميمة الريح', IK.talisman, 280,
      tier: 1, icon: 'talisman', agi: 4));
  a(const ItemDef('ward_talisman', 'تميمة الحماية', IK.talisman, 380,
      tier: 1, icon: 'talisman', def: 6));
  a(const ItemDef('qi_bead', 'خرزة الطاقة', IK.talisman, 560,
      tier: 2, icon: 'talisman', qi: 45));
  a(const ItemDef('fate_amulet', 'تميمة القدر', IK.talisman, 0,
      tier: 4, icon: 'talisman', luck: 6, hp: 40, tradable: false));
  // كتب التقنيات
  for (final t in techs.values) {
    if (t.bookPrice > 0) {
      m['book_${t.id}'] = ItemDef('book_${t.id}', 'كتاب: ${t.name}', IK.book, t.bookPrice,
          tier: t.tier, icon: 'book', tech: t.id,
          desc: 'يعلّمك تقنية ${t.name}.');
    }
  }
  return m;
}

ItemDef item(String id) =>
    items[id] ??
    ItemDef(id, id, IK.misc, 0, icon: 'gem', desc: 'عنصر مجهول');

/// قيمة تحسين السلاح
int enhancedAtk(int base, int plus) => (base * (1 + plus * 0.12)).round();
