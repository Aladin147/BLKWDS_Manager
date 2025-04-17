import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/studio.dart';

void main() {
  group('Studio Model Tests', () {
    test('Studio constructor creates instance with correct values', () {
      final studio = Studio(
        id: 1,
        name: 'Test Studio',
        type: StudioType.recording,
        description: 'Test Description',
        features: ['Feature 1', 'Feature 2'],
        hourlyRate: 100.0,
        status: StudioStatus.available,
        color: '#FF0000',
      );

      expect(studio.id, 1);
      expect(studio.name, 'Test Studio');
      expect(studio.type, StudioType.recording);
      expect(studio.description, 'Test Description');
      expect(studio.features, ['Feature 1', 'Feature 2']);
      expect(studio.hourlyRate, 100.0);
      expect(studio.status, StudioStatus.available);
      expect(studio.color, '#FF0000');
    });

    test('Studio.fromMap creates instance from map correctly', () {
      final map = {
        'id': 1,
        'name': 'Test Studio',
        'type': 'recording',
        'description': 'Test Description',
        'features': 'Feature 1,Feature 2',
        'hourlyRate': 100.0,
        'status': 'available',
        'color': '#FF0000',
      };

      final studio = Studio.fromMap(map);

      expect(studio.id, 1);
      expect(studio.name, 'Test Studio');
      expect(studio.type, StudioType.recording);
      expect(studio.description, 'Test Description');
      expect(studio.features, ['Feature 1', 'Feature 2']);
      expect(studio.hourlyRate, 100.0);
      expect(studio.status, StudioStatus.available);
      expect(studio.color, '#FF0000');
    });

    test('Studio.toMap converts instance to map correctly', () {
      final studio = Studio(
        id: 1,
        name: 'Test Studio',
        type: StudioType.production,
        description: 'Test Description',
        features: ['Feature 1', 'Feature 2'],
        hourlyRate: 100.0,
        status: StudioStatus.booked,
        color: '#FF0000',
      );

      final map = studio.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Test Studio');
      expect(map['type'], 'production');
      expect(map['description'], 'Test Description');
      expect(map['features'], 'Feature 1,Feature 2');
      expect(map['hourlyRate'], 100.0);
      expect(map['status'], 'booked');
      expect(map['color'], '#FF0000');
    });

    test('Studio.copyWith creates a new instance with updated values', () {
      final studio = Studio(
        id: 1,
        name: 'Test Studio',
        type: StudioType.recording,
        description: 'Test Description',
        features: ['Feature 1', 'Feature 2'],
        hourlyRate: 100.0,
        status: StudioStatus.available,
        color: '#FF0000',
      );

      final updatedStudio = studio.copyWith(
        name: 'Updated Studio',
        type: StudioType.production,
        description: 'Updated Description',
        features: ['Updated Feature'],
        hourlyRate: 200.0,
        status: StudioStatus.booked,
        color: '#00FF00',
      );

      // Original studio should not be changed
      expect(studio.name, 'Test Studio');
      expect(studio.type, StudioType.recording);
      expect(studio.description, 'Test Description');
      expect(studio.features, ['Feature 1', 'Feature 2']);
      expect(studio.hourlyRate, 100.0);
      expect(studio.status, StudioStatus.available);
      expect(studio.color, '#FF0000');

      // Updated studio should have new values
      expect(updatedStudio.id, 1);
      expect(updatedStudio.name, 'Updated Studio');
      expect(updatedStudio.type, StudioType.production);
      expect(updatedStudio.description, 'Updated Description');
      expect(updatedStudio.features, ['Updated Feature']);
      expect(updatedStudio.hourlyRate, 200.0);
      expect(updatedStudio.status, StudioStatus.booked);
      expect(updatedStudio.color, '#00FF00');
    });

    // Note: We can't test equality directly since Studio doesn't override ==
    // Instead, we'll test individual properties
    test('Studio properties comparison works correctly', () {
      final studio1 = Studio(
        id: 1,
        name: 'Test Studio',
        type: StudioType.recording,
      );

      final studio2 = Studio(
        id: 1,
        name: 'Test Studio',
        type: StudioType.recording,
      );

      final studio3 = Studio(
        id: 2,
        name: 'Test Studio',
        type: StudioType.recording,
      );

      expect(studio1.id, studio2.id);
      expect(studio1.name, studio2.name);
      expect(studio1.type, studio2.type);

      expect(studio1.id != studio3.id, true);
    });

    test('StudioType enum values are correct', () {
      expect(StudioType.values.length, 3); // recording, production, hybrid
      expect(StudioType.recording.toString(), 'StudioType.recording');
      expect(StudioType.production.toString(), 'StudioType.production');
      expect(StudioType.hybrid.toString(), 'StudioType.hybrid');
    });

    test('StudioStatus enum values are correct', () {
      expect(StudioStatus.values.length, 4); // available, booked, maintenance, unavailable
      expect(StudioStatus.available.toString(), 'StudioStatus.available');
      expect(StudioStatus.booked.toString(), 'StudioStatus.booked');
      expect(StudioStatus.maintenance.toString(), 'StudioStatus.maintenance');
      expect(StudioStatus.unavailable.toString(), 'StudioStatus.unavailable');
    });
  });
}
