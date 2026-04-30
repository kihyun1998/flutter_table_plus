import 'package:flutter/material.dart';

/// A widget that synchronizes multiple [ScrollController]s.
///
/// This is particularly useful for scenarios where different scrollable widgets
/// (e.g., a main content area and its corresponding scrollbar) need to scroll
/// in unison. It manages both vertical and horizontal scroll synchronization.
class SyncedScrollControllers extends StatefulWidget {
  /// Creates a [SyncedScrollControllers] instance.
  ///
  /// The [builder] function is required and provides the synchronized scroll
  /// controllers to its child widgets.
  ///
  /// [scrollController]: An optional external [ScrollController] for the main vertical scrollable area.
  ///   If not provided, an internal controller will be created.
  /// [verticalScrollbarController]: An optional external [ScrollController] for the vertical scrollbar.
  ///   If not provided, an internal controller will be created.
  /// [horizontalScrollController]: An optional external [ScrollController] for the body's horizontal scrollable area.
  ///   This controller is the master input source for horizontal scrolling.
  ///   If not provided, an internal controller will be created.
  /// [horizontalHeaderController]: An optional external [ScrollController] for the header's horizontal scrollable area.
  ///   The header is expected to have `physics: NeverScrollableScrollPhysics()` so that this controller is
  ///   driven exclusively by [horizontalScrollController]'s position changes (one-way sync).
  ///   If not provided, an internal controller will be created.
  /// [horizontalScrollbarController]: An optional external [ScrollController] for the horizontal scrollbar.
  ///   If not provided, an internal controller will be created.
  ///
  /// The `builder` function provides the following controllers:
  /// - `verticalDataController`: The primary controller for vertical scrolling of data.
  /// - `verticalScrollbarController`: The controller for the vertical scrollbar.
  /// - `horizontalBodyController`: The primary controller for horizontal scrolling of the body — receives user input.
  /// - `horizontalHeaderController`: The header's horizontal controller — slaved to the body controller.
  /// - `horizontalScrollbarController`: The controller for the horizontal scrollbar — bidirectionally synced with the body controller.
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.scrollController,
    this.verticalScrollbarController,
    this.horizontalScrollbarController,
    this.horizontalScrollController,
    this.horizontalHeaderController,
  });

  final ScrollController? scrollController;
  final ScrollController? verticalScrollbarController;
  final ScrollController? horizontalScrollController;
  final ScrollController? horizontalHeaderController;
  final ScrollController? horizontalScrollbarController;

  /// A builder function that provides the synchronized [ScrollController]s.
  ///
  /// [context]: The build context.
  /// [verticalDataController]: The primary controller for vertical scrolling of data.
  /// [verticalScrollbarController]: The controller for the vertical scrollbar.
  /// [horizontalBodyController]: The primary controller for horizontal scrolling of the body (master).
  /// [horizontalScrollbarController]: The controller for the horizontal scrollbar (bidirectional sync).
  /// [horizontalHeaderController]: The header's horizontal controller (one-way sync from body).
  final Widget Function(
    BuildContext context,
    ScrollController verticalDataController,
    ScrollController verticalScrollbarController,
    ScrollController horizontalBodyController,
    ScrollController horizontalScrollbarController,
    ScrollController horizontalHeaderController,
  ) builder;

  @override
  State<SyncedScrollControllers> createState() =>
      _SyncedScrollControllersState();
}

class _SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _sc11; // 메인 수직 (Scrollable Area 용)
  late ScrollController _sc12; // 수직 스크롤바
  ScrollController? _sc21; // 메인 수평 (body — master)
  late ScrollController _sc22; // 수평 스크롤바
  late ScrollController _sc23; // 수평 헤더 (body의 slave)

  // 각 컨트롤러에 대한 리스너들을 명확하게 관리하기 위한 Map
  final Map<ScrollController, VoidCallback> _listenersMap = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-initialize when external controllers actually change.
    // Previously this disposed and recreated ALL controllers on every parent
    // rebuild (e.g., hover setState), resetting scroll positions.
    if (widget.scrollController != oldWidget.scrollController ||
        widget.verticalScrollbarController !=
            oldWidget.verticalScrollbarController ||
        widget.horizontalScrollController !=
            oldWidget.horizontalScrollController ||
        widget.horizontalHeaderController !=
            oldWidget.horizontalHeaderController ||
        widget.horizontalScrollbarController !=
            oldWidget.horizontalScrollbarController) {
      _disposeOrUnsubscribe();
      _initControllers();
    }
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    // 수직 스크롤 컨트롤러 (메인, Scrollable Area 용)
    _sc11 = widget.scrollController ?? ScrollController();

    // 수평 스크롤 컨트롤러 (body — master input source for horizontal scroll)
    _sc21 = widget.horizontalScrollController ?? ScrollController();

    // 수직 스크롤바 컨트롤러
    _sc12 = widget.verticalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc11!.hasClients && _sc11!.positions.isNotEmpty
              ? _sc11!.offset
              : 0.0,
        );

    // 수평 스크롤바 컨트롤러
    _sc22 = widget.horizontalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc21!.hasClients && _sc21!.positions.isNotEmpty
              ? _sc21!.offset
              : 0.0,
        );

    // 수평 헤더 컨트롤러 (slave — body의 master 위치를 따라감)
    _sc23 = widget.horizontalHeaderController ??
        ScrollController(
          initialScrollOffset: _sc21!.hasClients && _sc21!.positions.isNotEmpty
              ? _sc21!.offset
              : 0.0,
        );

    // 각 쌍의 컨트롤러를 동기화합니다.
    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21!, _sc22);
    _syncScrollControllers(_sc21!, _sc23);
  }

  void _disposeOrUnsubscribe() {
    // 모든 리스너 제거
    _listenersMap.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listenersMap.clear();

    // 위젯에서 제공된 컨트롤러가 아니면 직접 dispose
    if (widget.scrollController == null) _sc11?.dispose();
    if (widget.horizontalScrollController == null) _sc21?.dispose();
    if (widget.verticalScrollbarController == null) _sc12.dispose();
    if (widget.horizontalScrollbarController == null) _sc22.dispose();
    if (widget.horizontalHeaderController == null) _sc23.dispose();
  }

  final Map<ScrollController, bool> _doNotReissueJump = {};

  void _syncScrollControllers(ScrollController master, ScrollController slave) {
    // 마스터 컨트롤러에 리스너 추가
    masterListener() => _jumpToNoCascade(master, slave);
    master.addListener(masterListener);
    _listenersMap[master] = masterListener;

    // 슬레이브 컨트롤러에 리스너 추가
    slaveListener() => _jumpToNoCascade(slave, master);
    slave.addListener(slaveListener);
    _listenersMap[slave] = slaveListener;
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    if (!master.hasClients || !slave.hasClients) {
      return;
    }

    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      final clampedOffset = master.offset.clamp(
        slave.position.minScrollExtent,
        slave.position.maxScrollExtent,
      );
      slave.jumpTo(clampedOffset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _sc11!,
        _sc12,
        _sc21!,
        _sc22,
        _sc23,
      );
}
