import 'package:flutter/widgets.dart';
import '../domain/craft_repository.dart';

class CraftScope extends InheritedNotifier<CraftRepository> {
  const CraftScope({
    super.key,
    required CraftRepository registry,
    required super.child,
  }) : super(notifier: registry);

  static CraftRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CraftScope>();
    assert(scope != null, 'CraftScope not found in context');
    return scope!.notifier!;
  }

  static CraftRepository read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<CraftScope>()
        ?.widget as CraftScope?;
    return scope!.notifier!;
  }
}
