TODO: TwoDimensionalScrollable를 사용해서 개선해야할듯

TODO: tooltip 제공해주자.

todo: row double click null 이면 duration 1로고정 ? or ㅇ안하게?





```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:acra_client/common/enum/style/enum_tooltip_position.dart';
import 'package:acra_client/extensions/theme/themedata_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomFlutterTooltip extends ConsumerWidget {
  /// position
  final TooltipPosition tooltipPosition;
  final EdgeInsetsGeometry? margin;

  /// duration
  final Duration? waitDuration;

  /// message
  final String? message;
  final TextStyle? textStyle;
  final InlineSpan? richMessage;

  /// color
  final Color? backgroundColor;

  /// child
  final Widget child;

  const CustomFlutterTooltip({
    super.key,
    this.tooltipPosition = TooltipPosition.bottom,
    this.margin,
    this.waitDuration,
    this.message,
    this.textStyle,
    this.richMessage,
    this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 30),
      textStyle: richMessage == null
          ? textStyle ?? ref.theme.font.mediumContentText12
          : textStyle,

      /// spacing
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      preferBelow: tooltipPosition == TooltipPosition.bottom,
      verticalOffset: 20,

      /// style
      decoration: BoxDecoration(
          color: backgroundColor ?? ref.theme.color.tooltipBackground,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(blurRadius: 3, color: ref.theme.color.shadowColor)
          ]),

      /// duration
      waitDuration: waitDuration ?? const Duration(milliseconds: 300),
      exitDuration: Duration.zero,
      showDuration: Duration.zero,
      message: message,
      richMessage: richMessage,
      child: child,
    );
  }
}

```