import 'package:flutter/material.dart';

/// Оборачивает поддерево виджетов и позволяет перезапустить его по запросу.
/// При вызове [restart] всё поддерево пересоздаётся с новым ключом,
/// что полезно при смене языка — все тексты подхватывают новый locale.
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  /// Вызывает перезагрузку поддерева. Передайте контекст из любого потомка.
  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restart();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
