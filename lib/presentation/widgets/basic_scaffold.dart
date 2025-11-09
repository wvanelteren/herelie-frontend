import 'package:flutter/material.dart';

class BasicScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget child;
  final Widget? bottomArea;
  final Widget? bottomNavigationBar;

  const BasicScaffold({
    super.key,
    this.title,
    this.actions,
    this.bottomArea,
    this.bottomNavigationBar,
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
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: bottomNavigationBar!,
              ),
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
