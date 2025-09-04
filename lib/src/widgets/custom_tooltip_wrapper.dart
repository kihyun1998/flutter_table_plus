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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Calculate available space above and below the target widget
    final customTheme = widget.theme.customWrapper;
    final padding = customTheme.spacingPadding;
    final spaceBelow = screenHeight - (offset.dy + size.height);
    final spaceAbove = offset.dy;
    final minSpace = customTheme.minSpace;
    
    // Estimate tooltip content height from theme
    final estimatedTooltipHeight = customTheme.estimatedHeight;
    
    // Smart positioning logic with overflow consideration
    bool showBelow;
    
    // Check if content will likely overflow
    bool willOverflowAbove = estimatedTooltipHeight > spaceAbove;
    bool willOverflowBelow = estimatedTooltipHeight > spaceBelow;
    
    if (willOverflowAbove && !willOverflowBelow) {
      // Content will overflow above but not below -> force below
      showBelow = true;
    } else if (!willOverflowAbove && willOverflowBelow) {
      // Content will overflow below but not above -> force above  
      showBelow = false;
    } else if (willOverflowAbove && willOverflowBelow) {
      // Will overflow both ways -> use intelligent space comparison
      final minScrollHeight = customTheme.minScrollHeight;
      
      if (widget.theme.preferBelow) {
        // Originally wanted below, but check if above has better scrolling space
        if (spaceAbove >= minScrollHeight && spaceAbove > spaceBelow) {
          showBelow = false; // Above has better scroll space
        } else {
          showBelow = true; // Stick with below preference or below has more space
        }
      } else {
        // Originally wanted above, but check if it's viable for scrolling
        if (spaceAbove >= minScrollHeight) {
          showBelow = false; // Above has enough space for scrolling
        } else if (spaceBelow >= minScrollHeight) {
          showBelow = true; // Above too narrow, use below
        } else {
          // Both too narrow, choose the larger one
          showBelow = spaceBelow > spaceAbove;
        }
      }
    } else {
      // No overflow expected -> use original preference logic
      if (widget.theme.preferBelow) {
        // Prefer below: only switch to above if below has no space but above does
        if (spaceBelow >= minSpace) {
          showBelow = true; // Enough space below
        } else if (spaceAbove >= minSpace) {
          showBelow = false; // Not enough below, but enough above
        } else {
          showBelow = true; // Both insufficient, stick to preference
        }
      } else {
        // Prefer above: only switch to below if above has no space but below does
        if (spaceAbove >= minSpace) {
          showBelow = false; // Enough space above
        } else if (spaceBelow >= minSpace) {
          showBelow = true; // Not enough above, but enough below
        } else {
          showBelow = false; // Both insufficient, stick to preference
        }
      }
    }

    // Calculate horizontal position with boundary checking
    final tooltipMaxWidth = customTheme.maxWidth;
    final horizontalPadding = customTheme.horizontalPadding;
    
    double leftPosition = offset.dx;
    double rightEdge = leftPosition + tooltipMaxWidth;
    
    // Adjust horizontal position if tooltip would go off-screen
    if (rightEdge > screenWidth - horizontalPadding) {
      // Move tooltip to the left so it fits
      leftPosition = screenWidth - tooltipMaxWidth - horizontalPadding;
    }
    // Ensure tooltip doesn't go off the left edge
    if (leftPosition < horizontalPadding) {
      leftPosition = horizontalPadding;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        Widget tooltipWidget = Container(
          constraints: BoxConstraints(
            maxWidth: tooltipMaxWidth,
            maxHeight: showBelow ? spaceBelow - padding : spaceAbove - padding,
          ),
          margin: widget.theme.margin,
          padding: widget.theme.padding,
          decoration: widget.theme.decoration,
          child: DefaultTextStyle(
            style: widget.theme.textStyle,
            child: SingleChildScrollView(
              child: widget.content,
            ),
          ),
        );

        Widget mouseRegionWidget = MouseRegion(
          onEnter: (_) {
            _isHovering = true; // Keep tooltip visible when mouse is over tooltip
          },
          onExit: (_) {
            _isHovering = false;
            Future.delayed(widget.theme.exitDuration, () {
              if (!_isHovering && mounted) {
                _removeTooltip();
              }
            });
          },
          child: tooltipWidget,
        );

        if (showBelow) {
          // Show tooltip below the target widget
          return Positioned(
            left: leftPosition,
            top: offset.dy + size.height + padding,
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: mouseRegionWidget,
              ),
            ),
          );
        } else {
          // Show tooltip above the target widget using bottom positioning
          return Positioned(
            left: leftPosition,
            bottom: screenHeight - offset.dy + padding,
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: mouseRegionWidget,
              ),
            ),
          );
        }
      },
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
    Future.delayed(widget.theme.exitDuration, () {
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