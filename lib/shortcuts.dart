// 📦 Package imports:
import 'package:quick_actions/quick_actions.dart';

class ShortcutItems {
  static final List<ShortcutItem> items = [
    timetable,
    applyLeave,
    fees,
    studentQR,
  ];

  static final ShortcutItem timetable = const ShortcutItem(
    type: "timetable",
    localizedTitle: "Timetable",
    icon: "icon_timetable",
  );
  static final ShortcutItem applyLeave = const ShortcutItem(
    type: "apply_leave",
    localizedTitle: "Apply Leave",
    icon: "icon_leave",
  );
  static final ShortcutItem fees = const ShortcutItem(
    type: "fees",
    localizedTitle: "Fees",
    icon: "icon_fees",
  );
  static final ShortcutItem studentQR = const ShortcutItem(
    type: "user",
    localizedTitle: "User",
    icon: "icon_user",
  );
}
