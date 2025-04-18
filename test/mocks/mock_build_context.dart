import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

/// A mock implementation of [BuildContext] for testing purposes.
class MockBuildContext extends Mock implements BuildContext {
  @override
  bool get mounted => true;

  @override
  bool get debugDoingBuild => false;

  @override
  Widget get widget => throw UnimplementedError();

  @override
  BuildOwner? get owner => throw UnimplementedError();

  @override
  RenderObject? get findRenderObject => throw UnimplementedError();

  @override
  Size? get size => throw UnimplementedError();

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement element, {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) {
    return null;
  }

  @override
  DiagnosticsNode describeElement(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  void dispatchNotification(Notification notification) {
    throw UnimplementedError();
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    return null;
  }

  @override
  RenderObject findRenderObjectOfType<T extends RenderObject>() {
    throw UnimplementedError();
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  @override
  BuildContext get parent => throw UnimplementedError();

  @override
  bool visitAncestorElements(bool Function(Element element) visitor) {
    return false;
  }

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  void visitChildren(ElementVisitor visitor) {}
}
