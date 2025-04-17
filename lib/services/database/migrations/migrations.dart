import '../migration.dart';
import 'migration_v1_to_v2.dart';
import 'migration_v2_to_v3.dart';
import 'migration_v3_to_v4.dart';
import 'migration_v4_to_v5.dart';
import 'migration_v5_to_v6.dart';
import 'migration_v6_to_v7.dart';
import 'migration_v7_to_v8.dart';

/// List of all migrations
final List<Migration> allMigrations = [
  MigrationV1ToV2(),
  MigrationV2ToV3(),
  MigrationV3ToV4(),
  MigrationV4ToV5(),
  MigrationV5ToV6(),
  MigrationV6ToV7(),
  MigrationV7ToV8(),
];
