class TechDef {
  final String id, name, cat, desc, fx, element;
  final int tier, minRealm, qi, bookPrice;
  final double cd, power;
  final bool passive;
  final String source; // book | azure | blood | verdant | secret
  const TechDef(this.id, this.name, this.cat, this.desc,
      {this.fx = '',
      this.element = 'metal',
      this.tier = 0,
      this.minRealm = 0,
      this.qi = 0,
      this.cd = 0,
      this.power = 1,
      this.passive = false,
      this.bookPrice = 0,
      this.source = 'book'});
}

const Map<String, String> techCatName = {
  'combat': 'قتالية',
  'defense': 'دفاعية',
  'move': 'حركة',
  'stealth': 'إخفاء',
  'heal': 'علاجية',
  'spirit': 'روحية',
  'rare': 'نادرة',
};

const Map<String, String> elemName = {
  'metal': 'معدن',
  'wood': 'خشب',
  'water': 'ماء',
  'fire': 'نار',
  'earth': 'أرض',
  'thunder': 'رعد',
  'shadow': 'ظل',
  'blood': 'دم',
  'spirit': 'روح',
};

const List<String> rootElements = ['metal', 'wood', 'water', 'fire', 'earth'];

final Map<String, TechDef> techs = _t();

Map<String, TechDef> _t() {
  final m = <String, TechDef>{};
  void a(TechDef t) => m[t.id] = t;
  // قتالية
  a(const TechDef('sword_wave', 'موجة السيف', 'combat',
      'تطلق موجة نصلية تخترق الأعداء في خط مستقيم.',
      fx: 'wave', qi: 10, cd: 3.5, power: 1.8, bookPrice: 180));
  a(const TechDef('flame_palm', 'كف اللهب', 'combat',
      'انفجار ناري أمامك يضرب كل ما قرب. العدو الجليدي ضعيف أمامه.',
      fx: 'palm', element: 'fire', qi: 14, cd: 5, power: 2.4, bookPrice: 260, tier: 1));
  a(const TechDef('thunder_fist', 'قبضة الرعد', 'combat',
      'اندفاعة سريعة تنتهي بلكمة صاعقة.',
      fx: 'fist', element: 'thunder', qi: 18, cd: 6, power: 2.8, bookPrice: 520, tier: 1, minRealm: 1));
  a(const TechDef('dragon_thrust', 'طعنة التنين', 'combat',
      'طعنة طويلة المدى تخترق الدروع.',
      fx: 'thrust', qi: 16, cd: 5.5, power: 3.0, bookPrice: 700, tier: 2, minRealm: 2));
  a(const TechDef('blood_slash', 'شق الدم', 'combat',
      'تضحّي بجزء من صحتك لضربة مدمّرة.',
      fx: 'bloodslash', element: 'blood', qi: 8, cd: 7, power: 4.2, tier: 2, minRealm: 2, source: 'blood'));
  a(const TechDef('azure_sword_art', 'فن سيف السحاب الأزرق', 'combat',
      'ثلاث موجات نصلية متتابعة من فنون طائفة السحاب الأزرق.',
      fx: 'tripwave', qi: 26, cd: 8, power: 2.4, tier: 3, minRealm: 3, source: 'azure'));
  a(const TechDef('shadow_blades', 'شفرات الظل', 'rare',
      'تستدعي شفرات ظلّية تلاحق الأعداء.',
      fx: 'blades', element: 'shadow', qi: 22, cd: 7, power: 2.0, tier: 3, minRealm: 3, source: 'secret'));
  a(const TechDef('sky_thunder', 'رعد السماء', 'rare',
      'صاعقة تضرب كل الأعداء على الشاشة.',
      fx: 'skythunder', element: 'thunder', qi: 45, cd: 14, power: 3.4, tier: 4, minRealm: 4, source: 'secret'));
  // دفاعية
  a(const TechDef('stone_skin', 'جلد الحجر', 'defense',
      'يضاعف دفاعك لفترة قصيرة.',
      fx: 'stoneskin', element: 'earth', qi: 12, cd: 14, power: 1.8, bookPrice: 240));
  a(const TechDef('qi_shield', 'درع الطاقة', 'defense',
      'درع طاقة يمتص كمية من الضرر.',
      fx: 'qishield', element: 'spirit', qi: 20, cd: 12, power: 1.0, bookPrice: 480, tier: 1, minRealm: 1));
  a(const TechDef('mirror_ward', 'حاجز المرآة', 'rare',
      'يعكس المقذوفات ويرد الضربة التالية.',
      fx: 'reflect', element: 'spirit', qi: 28, cd: 16, power: 2.0, tier: 3, minRealm: 3, source: 'secret'));
  // حركة
  a(const TechDef('wind_step', 'خطوة الريح', 'move',
      'اندفاعة سريعة بحصانة قصيرة.',
      fx: 'windstep', element: 'wood', qi: 6, cd: 2.5, bookPrice: 150));
  a(const TechDef('cloud_leap', 'قفزة السحاب', 'move',
      'قفزة عالية جداً.',
      fx: 'cloudleap', element: 'water', qi: 8, cd: 4, bookPrice: 300, tier: 1));
  a(const TechDef('void_step', 'خطوة الفراغ', 'rare',
      'انتقال فوري خلف أقرب عدو مع حصانة.',
      fx: 'voidstep', element: 'shadow', qi: 24, cd: 9, tier: 3, minRealm: 3, source: 'secret'));
  // علاجية
  a(const TechDef('spring_heal', 'ينبوع الشفاء', 'heal',
      'يشفيك بنسبة من صحتك الكلية.',
      fx: 'springheal', element: 'wood', qi: 20, cd: 18, power: 0.35, bookPrice: 380, tier: 1));
  a(const TechDef('verdant_renewal', 'التجدد الأخضر', 'heal',
      'تقنية وادي الحبوب: شفاء كبير مع إزالة السمّية.',
      fx: 'springheal', element: 'wood', qi: 30, cd: 20, power: 0.6, tier: 3, minRealm: 3, source: 'verdant'));
  // إخفاء (سلبية)
  a(const TechDef('hidden_breath', 'إخفاء الأنفاس', 'stealth',
      'سلبية: تقلل اللقاءات المعادية وتزيد فرص الهروب.',
      fx: 'stealth', passive: true, bookPrice: 280));
  a(const TechDef('shadow_cloak', 'عباءة الظل', 'stealth',
      'سلبية: تتفادى الكمائن وتزيد غنائم السرقة والبحث.',
      fx: 'ambush', passive: true, bookPrice: 650, tier: 2, minRealm: 2));
  // روحية (سلبية)
  a(const TechDef('heavenly_breath', 'تنفس السماء', 'spirit',
      'سلبية: +25% سرعة تدريب الزراعة.',
      fx: 'cultspeed', passive: true, bookPrice: 900, tier: 2, minRealm: 1));
  a(const TechDef('mind_calm', 'صفاء الذهن', 'spirit',
      'سلبية: يخفض خطر انحراف الطاقة ويرفع نجاح الاختراق.',
      fx: 'calm', passive: true, bookPrice: 760, tier: 2, minRealm: 1));
  a(const TechDef('soul_sense', 'حسّ الروح', 'spirit',
      'سلبية: يزيد العثور على الكنوز والأسرار.',
      fx: 'sense', passive: true, bookPrice: 840, tier: 2, minRealm: 1));
  a(const TechDef('herb_mastery', 'حكمة الأعشاب', 'spirit',
      'سلبية: ترفع نجاح صناعة الحبوب والمحصول.',
      fx: 'herb', passive: true, bookPrice: 420, tier: 1));
  a(const TechDef('nine_turns', 'الدورات التسع', 'rare',
      'سلبية: تدريب الجسد أقوى بـ50% و+12% صحة.',
      fx: 'body', passive: true, tier: 3, minRealm: 2, source: 'secret'));
  a(const TechDef('fate_glimpse', 'لمحة القدر', 'rare',
      'تبطئ الزمن لحظات في القتال، وتكشف نذر الأحداث.',
      fx: 'fateglimpse', element: 'spirit', qi: 35, cd: 22, tier: 4, minRealm: 2, source: 'secret'));
  return m;
}

TechDef tech(String id) => techs[id]!;

/// قوة التقنية حسب الإتقان 1-5
double masteryMul(int lvl) => 1 + 0.22 * (lvl - 1);
int masteryNeed(int lvl) => 20 * lvl * lvl; // خبرة الإتقان للمستوى التالي
