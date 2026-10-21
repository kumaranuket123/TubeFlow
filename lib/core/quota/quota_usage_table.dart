import 'package:drift/drift.dart';

/// YouTube Data API units spent per Pacific-time day (when the quota resets).
@DataClassName('QuotaUsageRow')
class QuotaUsage extends Table {
  TextColumn get dayKey => text()();
  IntColumn get units => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dayKey};
}
