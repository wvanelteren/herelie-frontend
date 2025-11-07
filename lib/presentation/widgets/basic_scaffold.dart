import 'package:flutter/material.dart';

class BasicScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget child;
  final Widget? bottomArea;

  const BasicScaffold({
    super.key,
    this.title,
    this.actions,
    this.bottomArea,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              centerTitle: false,
              actions: actions,
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: child),
              if (bottomArea != null) ...[
                const SizedBox(height: 16),
                bottomArea!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
