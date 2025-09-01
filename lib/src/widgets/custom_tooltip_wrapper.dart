import 'package:flutter/material.dart';
import 'package:flutter_table_plus/src/models/theme/tooltip_theme.dart';

/// A wrapper widget that provides custom widget tooltip functionality
/// while integrating with the existing TablePlusTooltipTheme system.
/// 
/// This widget uses an overlay-based approach to display rich content tooltips
/// that can contain any Flutter widget, not just text.
class CustomTooltipWrapper extends StatefulWidget {
  /// Creates a [CustomTooltipWrapper] with the specified content and theme.
  const CustomTooltipWrapper({
    super.key,
    required this.content,
    required this.child,
    required this.theme,
  });

  /// The custom widget content to display in the tooltip.
  final Widget content;

  /// The child widget that triggers the tooltip when hovered.
  final Widget child;

  /// The tooltip theme configuration.
  final TablePlusTooltipTheme theme;

  @override
  State<CustomTooltipWrapper> createState() => _CustomTooltipWrapperState();
}

class _CustomTooltipWrapperState extends State<CustomTooltipWrapper>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _removeTooltip();
    _animationController?.dispose();
    super.dispose();
  }

  void _showTooltip() {
    if (_overlayEntry != null || !widget.theme.enabled) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: widget.theme.preferBelow
            ? offset.dy + size.height + 8
            : offset.dy - 8,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              margin: widget.theme.margin,
              padding: widget.theme.padding,
              decoration: widget.theme.decoration,
              child: DefaultTextStyle(
                style: widget.theme.textStyle,
                child: widget.content,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _animationController?.forward();
  }

  void _removeTooltip() {
    if (_overlayEntry != null) {
      _animationController?.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  void _handlePointerEnter() {
    _isHovering = true;
    Future.delayed(widget.theme.waitDuration, () {
      if (_isHovering && mounted) {
        _showTooltip();
      }
    });
  }

  void _handlePointerExit() {
    _isHovering = false;
    Future.delayed(widget.theme.showDuration, () {
      if (!_isHovering && mounted) {
        _removeTooltip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handlePointerEnter(),
      onExit: (_) => _handlePointerExit(),
      child: widget.child,
    );
  }
}