import 'dart:math';
import '../models/models.dart';

/// DataGenerator
/// Utility class for generating random data
class DataGenerator {
  static final Random _random = Random();

  /// Generate a random integer between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Generate a random double between min and max
  static double randomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  /// Generate a random boolean
  static bool randomBool() {
    return _random.nextBool();
  }

  /// Generate a random date between start and end
  static DateTime randomDate(DateTime start, DateTime end) {
    final difference = end.difference(start).inDays;
    return start.add(Duration(days: _random.nextInt(difference)));
  }

  /// Generate a random time between start and end
  static CustomTimeOfDay randomTime(CustomTimeOfDay start, CustomTimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final randomMinutes = randomInt(startMinutes, endMinutes);
    return CustomTimeOfDay(
      hour: randomMinutes ~/ 60,
      minute: randomMinutes % 60,
    );
  }

  /// Generate a random item from a list
  static T randomItem<T>(List<T> items) {
    return items[_random.nextInt(items.length)];
  }

  /// Generate a random subset of a list
  static List<T> randomSubset<T>(List<T> items, int min, int max) {
    final count = randomInt(min, max);
    final shuffled = List<T>.from(items)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Generate a random name
  static String randomName() {
    final firstNames = [
      'Alex', 'Jordan', 'Taylor', 'Sam', 'Casey', 'Morgan', 'Riley',
      'Jamie', 'Quinn', 'Avery', 'Blake', 'Cameron', 'Charlie', 'Dakota',
      'Drew', 'Emerson', 'Finley', 'Hayden', 'Kai', 'Lane', 'Micah',
      'Parker', 'Peyton', 'Reese', 'Rowan', 'Sage', 'Skyler', 'Tatum',
    ];

    final lastNames = [
      'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller',
      'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White',
      'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 'Clark',
      'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young',
    ];

    return '${randomItem(firstNames)} ${randomItem(lastNames)}';
  }

  /// Generate a random role
  static String randomRole() {
    final roles = [
      'Director', 'Producer', 'Cinematographer', 'Sound Engineer',
      'Gaffer', 'Grip', 'Production Assistant', 'Editor',
      'VFX Artist', 'Colorist', 'Set Designer', 'Costume Designer',
      'Makeup Artist', 'Script Supervisor', 'Location Manager',
    ];

    return randomItem(roles);
  }

  /// Generate a random gear name
  static String randomGearName() {
    final brands = [
      'Canon', 'Sony', 'Panasonic', 'Blackmagic', 'RED', 'ARRI',
      'DJI', 'Zhiyun', 'Sennheiser', 'Rode', 'Aputure', 'Godox',
      'Manfrotto', 'Gitzo', 'Sigma', 'Tamron', 'Zeiss', 'Samyang',
    ];

    final models = [
      'R6', 'A7III', 'GH5', 'Pocket 6K', 'Komodo', 'Alexa Mini',
      'Ronin', 'Crane 3', 'MKH416', 'NTG3', '120D', 'SL60W',
      'MT055', 'GT3543', '24-70mm f/2.8', '70-200mm f/2.8', 'Milvus 50mm', '85mm T1.5',
    ];

    return '${randomItem(brands)} ${randomItem(models)}';
  }

  /// Generate a random gear category
  static String randomGearCategory() {
    final categories = [
      'Camera', 'Lens', 'Audio', 'Lighting', 'Stabilizer',
      'Support', 'Power', 'Storage', 'Monitor', 'Grip',
    ];

    return randomItem(categories);
  }

  /// Generate a random project title
  static String randomProjectTitle() {
    final adjectives = [
      'Epic', 'Vibrant', 'Mysterious', 'Enchanted', 'Radiant',
      'Serene', 'Dynamic', 'Ethereal', 'Vivid', 'Majestic',
      'Whimsical', 'Nostalgic', 'Surreal', 'Captivating', 'Luminous',
    ];

    final nouns = [
      'Journey', 'Odyssey', 'Vision', 'Horizon', 'Reflection',
      'Perspective', 'Essence', 'Harmony', 'Rhythm', 'Spectrum',
      'Cascade', 'Mosaic', 'Prism', 'Echo', 'Silhouette',
    ];

    return '${randomItem(adjectives)} ${randomItem(nouns)}';
  }

  /// Generate a random client name
  static String randomClientName() {
    final prefixes = [
      'Global', 'Elite', 'Prime', 'Apex', 'Zenith',
      'Pinnacle', 'Summit', 'Vanguard', 'Horizon', 'Quantum',
      'Fusion', 'Nexus', 'Vertex', 'Catalyst', 'Synergy',
    ];

    final suffixes = [
      'Media', 'Productions', 'Studios', 'Films', 'Entertainment',
      'Creative', 'Visuals', 'Pictures', 'Arts', 'Collective',
      'Group', 'Network', 'Agency', 'Partners', 'Associates',
    ];

    return '${randomItem(prefixes)} ${randomItem(suffixes)}';
  }

  /// Generate a random booking title
  static String randomBookingTitle() {
    final types = [
      'Commercial', 'Music Video', 'Documentary', 'Short Film',
      'Interview', 'Corporate', 'Event', 'Wedding', 'Product',
      'Fashion', 'Travel', 'Sports', 'Lifestyle', 'Educational',
    ];

    final activities = [
      'Shoot', 'Production', 'Filming', 'Recording', 'Session',
      'Capture', 'Coverage', 'Project', 'Assignment', 'Work',
    ];

    return '${randomItem(types)} ${randomItem(activities)}';
  }

  /// Generate a random note
  static String randomNote() {
    final notes = [
      'Battery at 50%', 'New SD card installed', 'Needs calibration soon',
      'Left lens cap in studio', 'Slight scratch on body', 'Firmware updated',
      'Missing lens hood', 'Tripod plate loose', 'Audio cable frayed',
      'Light stand wobbly', 'Needs new batteries', 'Memory card formatted',
    ];

    return randomItem(notes);
  }

  /// Generate a random Member
  static Member randomMember() {
    return Member(
      name: randomName(),
      role: randomRole(),
      email: '${randomName().toLowerCase().replaceAll(' ', '.')}@example.com',
      phone: '+1${randomInt(100, 999)}${randomInt(100, 999)}${randomInt(1000, 9999)}',
      notes: randomBool() ? randomNote() : null,
    );
  }

  /// Generate a random Gear
  static Gear randomGear() {
    final category = randomGearCategory();
    return Gear(
      name: randomGearName(),
      category: category,
      serialNumber: randomBool() ? '${category[0]}${randomInt(10000, 99999)}' : null,
      purchaseDate: randomBool() ? randomDate(
        DateTime.now().subtract(const Duration(days: 365 * 3)),
        DateTime.now(),
      ) : null,
      purchasePrice: randomBool() ? randomDouble(100, 5000) : null,
      notes: randomBool() ? randomNote() : null,
      isOut: randomBool(),
      lastNote: randomBool() ? randomNote() : null,
    );
  }

  /// Generate a random Project
  static Project randomProject({List<int>? memberIds}) {
    return Project(
      title: randomProjectTitle(),
      client: randomClientName(),
      notes: randomBool() ? randomNote() : null,
      memberIds: memberIds != null && memberIds.isNotEmpty
          ? randomSubset(memberIds, 1, memberIds.length)
          : [],
    );
  }

  /// Generate a random Booking
  static Booking randomBooking({
    List<int>? projectIds,
    List<int>? gearIds,
    List<int>? memberIds,
    List<int>? studioIds,
    bool includePastData = true,
    bool includeFutureData = true,
  }) {
    final now = DateTime.now();
    final startDate = randomDate(
      includePastData
          ? now.subtract(const Duration(days: 30))
          : now,
      includeFutureData
          ? now.add(const Duration(days: 30))
          : now,
    );

    final durationHours = randomInt(1, 8);
    final endDate = startDate.add(Duration(hours: durationHours));

    final selectedGearIds = gearIds != null && gearIds.isNotEmpty
        ? randomSubset(gearIds, 1, min(5, gearIds.length))
        : <int>[];

    final assignedGearToMember = <int, int>{};
    if (memberIds != null && memberIds.isNotEmpty && selectedGearIds.isNotEmpty) {
      for (final gearId in selectedGearIds) {
        if (randomBool()) {
          assignedGearToMember[gearId] = randomItem(memberIds);
        }
      }
    }

    return Booking(
      projectId: projectIds != null && projectIds.isNotEmpty
          ? randomItem(projectIds)
          : -1,
      title: randomBookingTitle(),
      startDate: startDate,
      endDate: endDate,
      studioId: studioIds != null && studioIds.isNotEmpty && randomBool()
          ? randomItem(studioIds)
          : null,
      gearIds: selectedGearIds,
      assignedGearToMember: assignedGearToMember.isNotEmpty
          ? assignedGearToMember
          : null,
      notes: randomBool() ? randomNote() : null,
    );
  }

  /// Generate a random ActivityLog
  static ActivityLog randomActivityLog({
    List<int>? gearIds,
    List<int>? memberIds,
    bool includePastData = true,
    bool includeFutureData = false,
  }) {
    final now = DateTime.now();
    final timestamp = randomDate(
      includePastData
          ? now.subtract(const Duration(days: 30))
          : now,
      includeFutureData
          ? now.add(const Duration(days: 30))
          : now,
    );

    final checkedOut = randomBool();

    return ActivityLog(
      gearId: gearIds != null && gearIds.isNotEmpty
          ? randomItem(gearIds)
          : -1,
      memberId: memberIds != null && memberIds.isNotEmpty && (checkedOut || randomBool())
          ? randomItem(memberIds)
          : null,
      checkedOut: checkedOut,
      timestamp: timestamp,
      note: randomBool() ? randomNote() : null,
    );
  }

  /// Generate a random StatusNote
  static StatusNote randomStatusNote({
    List<int>? gearIds,
    bool includePastData = true,
    bool includeFutureData = false,
  }) {
    final now = DateTime.now();
    final timestamp = randomDate(
      includePastData
          ? now.subtract(const Duration(days: 30))
          : now,
      includeFutureData
          ? now.add(const Duration(days: 30))
          : now,
    );

    return StatusNote(
      gearId: gearIds != null && gearIds.isNotEmpty
          ? randomItem(gearIds)
          : -1,
      note: randomNote(),
      timestamp: timestamp,
    );
  }

  /// Generate a random Studio
  static Studio randomStudio() {
    final names = [
      'Main Studio', 'Production Studio', 'Recording Studio', 'Green Screen Studio',
      'Interview Room', 'Sound Stage', 'Editing Suite', 'VFX Lab',
      'Podcast Room', 'Photography Studio', 'Screening Room', 'Conference Room',
    ];

    // Use the StudioType enum values
    final studioTypes = StudioType.values;

    final name = randomItem(names);
    final type = randomItem(studioTypes);
    final description = randomBool() ? 'A ${type.label} studio for professional use.' : null;
    final List<String> features = randomBool()
        ? <String>['Wi-Fi', 'Air Conditioning', 'Sound Proofing', 'Natural Light']
            .take(randomInt(1, 4)).toList()
        : <String>[];

    return Studio(
      name: name,
      type: type,
      description: description,
      features: features,
      hourlyRate: randomBool() ? randomDouble(50, 200) : null,
      status: randomItem(StudioStatus.values),
      color: randomBool() ? '#${randomInt(0, 0xFFFFFF).toRadixString(16).padLeft(6, '0')}' : null,
    );
  }
}
