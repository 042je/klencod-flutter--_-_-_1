import 'dart:math';

class RealmDef {
  final String name, desc, trial;
  final int subs, life;
  final Map<String, int> need; // عناصر الاختراق إلى المرحلة التالية
  final double baseChance;
  final double densityMin;
  const RealmDef(this.name, this.subs, this.life, this.desc,
      {this.need = const {},
      this.baseChance = 0.6,
      this.trial = 'none',
      this.densityMin = 0});
}

// trial: none | demon | lightning | heaven
const List<RealmDef> realms = [
  RealmDef('صقل الجسد', 9, 0,
      'جسد بشري يُصقل بالتمارين. تحتاج استشعار الطاقة لتتجاوزه.',
      need: {'qi_pill': 2}, baseChance: 0.55, densityMin: 0.5),
  RealmDef('استشعار الطاقة الروحية', 6, 12,
      'تبدأ بإحساس التدفق الروحي في الهواء. يُكشف جذرك الروحي.',
      need: {'qi_pill': 3}, baseChance: 0.6),
  RealmDef('تجميع الطاقة', 9, 28,
      'تتجمع الطاقة في بحر الدانتيان داخل جسدك.',
      need: {'foundation_pill': 1}, baseChance: 0.5, trial: 'demon'),
  RealmDef('تأسيس الأساس', 3, 55,
      'يتصلّب بحر الطاقة. أول مرحلة تتجاوز بها حدود الفانين.',
      need: {'core_pill': 1}, baseChance: 0.45, trial: 'demon'),
  RealmDef('تكوين النواة', 3, 110,
      'تتكثف الطاقة إلى نواة ذهبية. عمر طويل وقوة هائلة.',
      need: {'nascent_pill': 1}, baseChance: 0.4, trial: 'demon'),
  RealmDef('الروح الوليدة', 3, 220,
      'تولد روح ثانية داخل نواتك. تبدأ المحن السماوية.',
      need: {'soul_flower': 2, 'beast_core_3': 2},
      baseChance: 0.38, trial: 'lightning'),
  RealmDef('التحول الروحي', 3, 450,
      'تذوب الحدود بين الجسد والروح.',
      need: {'star_silver': 2, 'cold_jade': 2},
      baseChance: 0.36, trial: 'lightning'),
  RealmDef('الصعود السماوي', 3, 900,
      'تقف على عتبة السماوات. الخطوة التالية لا يعرفها إلا من رأى ما وراء الحدود.',
      need: {'dawn_lotus': 1, 'soul_flower': 3},
      baseChance: 0.3, trial: 'heaven'),
  RealmDef('الخلود', 3, 100000,
      'تجاوزت دورة الحياة والموت. عمرك بلا حدود.'),
];

const List<String> immortalSub = ['خالد فانٍ', 'خالد حقيقي', 'خالد سماوي'];
const List<String> threeSub = ['المبكر', 'المتوسط', 'المتأخر'];

String subName(int realm, int sub) {
  final r = realms[realm];
  if (realm == 8) return immortalSub[(sub - 1).clamp(0, 2)];
  if (r.subs == 3) return threeSub[(sub - 1).clamp(0, 2)];
  return 'المستوى $sub';
}

/// فهرس المستوى الكلي 0..
int globalIdx(int realm, int sub) {
  int g = 0;
  for (int i = 0; i < realm; i++) {
    g += realms[i].subs;
  }
  return g + sub - 1;
}

int totalLevels() {
  int g = 0;
  for (final r in realms) {
    g += r.subs;
  }
  return g;
}

/// خبرة الزراعة اللازمة للمستوى الفرعي الحالي
double xpNeed(int realm, int sub) =>
    100 * pow(1.42, globalIdx(realm, sub)).toDouble();

/// مقياس القوة
double powerScale(int gi) => pow(1.11, gi).toDouble();

/// نمو اكتساب الخبرة مع المستوى
double gainScale(int gi) => pow(1.30, gi).toDouble();

const List<String> rootNames = ['معدن', 'خشب', 'ماء', 'نار', 'أرض'];
const List<String> purityNames = ['', 'مشوّه', 'ثنائي', 'جيد', 'نقي', 'سماوي'];

/// مراحل العمر بالنسبة لعمر الجسد
String ageStage(int age, int lifespan) {
  if (age < 12) return 'طفولة';
  if (age < 18) return 'فتوّة';
  final r = age / lifespan;
  if (r < 0.3) return 'شباب';
  if (r < 0.55) return 'نضج';
  if (r < 0.75) return 'منتصف العمر';
  if (r < 0.92) return 'شيخوخة';
  return 'خريف العمر';
}

/// معامل ضعف الشيخوخة 0..0.4
double agePenalty(int age, int lifespan) {
  final r = age / lifespan;
  if (r <= 0.6) return 0;
  return ((r - 0.6) / 0.4 * 0.4).clamp(0.0, 0.4);
}
