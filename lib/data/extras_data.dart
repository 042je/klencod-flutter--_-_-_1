class PetDef {
  final String id, name, desc;
  const PetDef(this.id, this.name, this.desc);
}

const List<PetDef> petDefs = [
  PetDef('fox', 'ثعلب روحي', 'غنائم الصيد أكثر (+5% لكل مستوى)'),
  PetDef('tiger', 'شبل النمر الأبيض', 'قوة قتالية أعلى (+6% لكل مستوى)'),
  PetDef('turtle', 'سلحفاة اليشم', 'صحة أكبر (+5 لكل مستوى)'),
  PetDef('bird', 'طائر الرعد', 'تدريب أسرع (+3% لكل مستوى)'),
];

const List<String> mateClasses = ['مقاتل', 'ساحر', 'معالج', 'رامٍ'];
const List<String> mateDesc = [
  'قوة هجومية متوازنة',
  'قوة أعلى بـ20%',
  'يداوي فريقك بعد كل معركة',
  'ضرر ثابت من بعيد',
];

/// نتيجة معركة الحملة (تُحسب مسبقاً ثم تُعرض كرسوم متحركة)
class BattleInfo {
  final String err;
  final bool win, boss;
  final int stage;
  final String name, kind, rewards;
  final double power, epower;
  const BattleInfo(
      {this.err = '',
      this.win = false,
      this.boss = false,
      this.stage = 1,
      this.name = '',
      this.kind = 'wolf',
      this.rewards = '',
      this.power = 0,
      this.epower = 1});
}

const List<String> dailyNames = [
  'فضة', 'حبتا طاقة', '3 حبوب شفاء', 'حبة صقل الجسد', 'فضة كبيرة', 'نواتا وحش', 'بيضة روحية'
];
