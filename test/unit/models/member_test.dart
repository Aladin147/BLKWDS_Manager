import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/member.dart';

void main() {
  group('Member Model Tests', () {
    test('Member constructor creates instance with correct values', () {
      final member = Member(
        id: 1,
        name: 'Test User',
        role: 'Tester',
      );

      expect(member.id, 1);
      expect(member.name, 'Test User');
      expect(member.role, 'Tester');
    });

    test('Member.fromMap creates instance from map correctly', () {
      final map = {
        'id': 1,
        'name': 'Test User',
        'role': 'Tester',
      };

      final member = Member.fromMap(map);

      expect(member.id, 1);
      expect(member.name, 'Test User');
      expect(member.role, 'Tester');
    });

    test('Member.toMap converts instance to map correctly', () {
      final member = Member(
        id: 1,
        name: 'Test User',
        role: 'Tester',
      );

      final map = member.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Test User');
      expect(map['role'], 'Tester');
    });

    test('Member.copyWith creates a new instance with updated values', () {
      final member = Member(
        id: 1,
        name: 'Test User',
        role: 'Tester',
      );

      final updatedMember = member.copyWith(
        name: 'Updated User',
        role: 'Updated Role',
      );

      // Original member should not be changed
      expect(member.name, 'Test User');
      expect(member.role, 'Tester');

      // Updated member should have new values
      expect(updatedMember.id, 1);
      expect(updatedMember.name, 'Updated User');
      expect(updatedMember.role, 'Updated Role');
    });

    test('Member equality works correctly', () {
      final member1 = Member(
        id: 1,
        name: 'Test User',
        role: 'Tester',
      );

      final member2 = Member(
        id: 1,
        name: 'Test User',
        role: 'Tester',
      );

      final member3 = Member(
        id: 2,
        name: 'Test User',
        role: 'Tester',
      );

      expect(member1 == member2, true);
      expect(member1 == member3, false);
      expect(member1.hashCode == member2.hashCode, true);
      expect(member1.hashCode == member3.hashCode, false);
    });
  });
}
