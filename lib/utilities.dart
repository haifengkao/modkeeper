import 'package:flutter/material.dart';

extension VisibilityExtension on Widget {
  Widget visibility(bool isVisible) {
    return Visibility(
      visible: isVisible,
      child: this,
    );
  }
}
class FutureLoadingWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final Widget? loadingWidget;
  final Widget Function(Object? error)? errorWidget;

  const FutureLoadingWidget({
    super.key,
    required this.future,
    required this.dataBuilder,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show the custom loading widget or a default one if not provided
          return loadingWidget ?? const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          // Show the custom error widget or a default one if not provided
          return errorWidget?.call(snapshot.error) ?? Text('Error: ${snapshot.error}');
        }
        // Data is available, use the dataBuilder to build the widget
        return dataBuilder(context, snapshot.data as T);
      },
    );
  }
}