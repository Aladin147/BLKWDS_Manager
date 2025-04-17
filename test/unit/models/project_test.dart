import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/project.dart';

void main() {
  group('Project Model Tests', () {
    test('Project constructor creates instance with correct values', () {
      final project = Project(
        id: 1,
        title: 'Test Project',
        client: 'Test Client',
        notes: 'Test Notes',
        memberIds: [1, 2, 3],
      );

      expect(project.id, 1);
      expect(project.title, 'Test Project');
      expect(project.client, 'Test Client');
      expect(project.notes, 'Test Notes');
      expect(project.memberIds, [1, 2, 3]);
      expect(project.description, null);
    });

    test('Project.fromMap creates instance from map correctly', () {
      final map = {
        'id': 1,
        'title': 'Test Project',
        'client': 'Test Client',
        'notes': 'Test Notes',
      };

      final project = Project.fromMap(map);

      expect(project.id, 1);
      expect(project.title, 'Test Project');
      expect(project.client, 'Test Client');
      expect(project.notes, 'Test Notes');
      expect(project.memberIds, isEmpty);
      expect(project.description, null);
    });

    test('Project.toMap converts instance to map correctly', () {
      final project = Project(
        id: 1,
        title: 'Test Project',
        client: 'Test Client',
        notes: 'Test Notes',
        memberIds: [1, 2, 3],
      );

      final map = project.toMap();

      expect(map['id'], 1);
      expect(map['title'], 'Test Project');
      expect(map['client'], 'Test Client');
      expect(map['notes'], 'Test Notes');
      // memberIds is not included in toMap as it's stored in a separate table
      expect(map.containsKey('memberIds'), false);
    });

    test('Project.copyWith creates a new instance with updated values', () {
      final project = Project(
        id: 1,
        title: 'Test Project',
        client: 'Test Client',
        notes: 'Test Notes',
        memberIds: [1, 2, 3],
      );

      final updatedProject = project.copyWith(
        title: 'Updated Project',
        client: 'Updated Client',
        memberIds: [4, 5],
      );

      // Original project should not be changed
      expect(project.title, 'Test Project');
      expect(project.client, 'Test Client');
      expect(project.memberIds, [1, 2, 3]);

      // Updated project should have new values
      expect(updatedProject.id, 1);
      expect(updatedProject.title, 'Updated Project');
      expect(updatedProject.client, 'Updated Client');
      expect(updatedProject.notes, 'Test Notes');
      expect(updatedProject.memberIds, [4, 5]);
    });

    test('Project equality works correctly', () {
      final project1 = Project(
        id: 1,
        title: 'Test Project',
        client: 'Test Client',
        notes: 'Test Notes',
        memberIds: [1, 2, 3],
      );

      final project2 = Project(
        id: 1,
        title: 'Test Project',
        client: 'Test Client',
        notes: 'Test Notes',
        memberIds: [1, 2, 3],
      );

      final project3 = Project(
        id: 2,
        title: 'Test Project',
        client: 'Test Client',
        notes: 'Test Notes',
        memberIds: [1, 2, 3],
      );

      expect(project1 == project2, true);
      expect(project1 == project3, false);
      expect(project1.hashCode == project2.hashCode, true);
      expect(project1.hashCode == project3.hashCode, false);
    });
  });
}
