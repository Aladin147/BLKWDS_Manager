import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:mockito/mockito.dart';

// Mock implementations for File and Directory classes

/// A mock implementation of [io.Directory] for testing purposes.
class MockDirectory extends Mock implements io.Directory {
  final String _path;
  final bool _exists;
  final List<io.FileSystemEntity> _entities;

  MockDirectory({
    String path = '/mock/path',
    bool exists = true,
    List<io.FileSystemEntity> entities = const [],
  })  : _path = path,
        _exists = exists,
        _entities = entities;

  @override
  String get path => _path;

  @override
  Future<bool> exists() async => _exists;

  @override
  Future<io.Directory> create({bool recursive = false}) async => this;

  @override
  Stream<io.FileSystemEntity> list({
    bool recursive = false,
    bool followLinks = true,
  }) {
    return Stream.fromIterable(_entities);
  }

  @override
  Future<io.Directory> createTemp([String? prefix]) async {
    return MockDirectory(
      path: '$_path/${prefix ?? 'temp'}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  io.Directory get parent => MockDirectory(path: _path.substring(0, _path.lastIndexOf('/')));

  @override
  Future<io.FileSystemEntity> delete({bool recursive = false}) async => this;
}

/// A mock implementation of [io.File] for testing purposes.
class MockFile extends Mock implements io.File {
  final String _path;
  final bool _exists;
  String _content;
  final DateTime _lastModified;

  MockFile({
    String path = '/mock/path/file.txt',
    bool exists = true,
    String content = '',
    DateTime? lastModified,
  })  : _path = path,
        _exists = exists,
        _content = content,
        _lastModified = lastModified ?? DateTime.now();

  @override
  String get path => _path;

  @override
  Future<bool> exists() async => _exists;

  @override
  Future<io.File> create({bool recursive = false, bool exclusive = false}) async => this;

  @override
  Future<io.File> writeAsString(
    String contents, {
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    _content = contents;
    return this;
  }

  @override
  Future<io.File> writeAsBytes(
    List<int> bytes, {
    io.FileMode mode = io.FileMode.write,
    bool flush = false,
  }) async {
    _content = utf8.decode(bytes);
    return this;
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async => _content;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List.fromList(utf8.encode(_content));

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) async => _content.split('\n');

  @override
  Future<int> length() async => _content.length;

  @override
  Future<DateTime> lastModified() async => _lastModified;

  @override
  Future<io.FileSystemEntity> delete({bool recursive = false}) async => this;

  @override
  io.Directory get parent => MockDirectory(path: _path.substring(0, _path.lastIndexOf('/')));

  @override
  String get basename => _path.substring(_path.lastIndexOf('/') + 1);
}
