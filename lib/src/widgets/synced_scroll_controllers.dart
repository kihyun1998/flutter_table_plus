import 'package:flutter/material.dart';

/// A widget that synchronizes multiple [ScrollController]s.
///
/// This widget manages scroll synchronization for the unified table approach,
/// where a single ListView handles both frozen and scrollable columns.
/// It synchronizes vertical and horizontal scrolling with their respective scrollbars.
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
  /// [horizontalScrollController]: An optional external [ScrollController] for the main horizontal scrollable area.
  ///   If not provided, an internal controller will be created.
  /// [horizontalScrollbarController]: An optional external [ScrollController] for the horizontal scrollbar.
  ///   If not provided, an internal controller will be created.
  ///
  /// The `builder` function provides the following controllers:
  /// - `verticalDataController`: The primary controller for vertical scrolling of data.
  /// - `verticalScrollbarController`: The controller for the vertical scrollbar.
  /// - `horizontalMainController`: The primary controller for horizontal scrolling.
  /// - `horizontalScrollbarController`: The controller for the horizontal scrollbar.
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.scrollController,
    this.verticalScrollbarController,
    this.horizontalScrollbarController,
    this.horizontalScrollController,
  });

  final ScrollController? scrollController;
  final ScrollController? verticalScrollbarController;
  final ScrollController? horizontalScrollController;
  final ScrollController? horizontalScrollbarController;

  /// A builder function that provides the synchronized [ScrollController]s.
  ///
  /// [context]: The build context.
  /// [verticalDataController]: The primary controller for vertical scrolling of data.
  /// [verticalScrollbarController]: The controller for the vertical scrollbar.
  /// [horizontalMainController]: The primary controller for horizontal scrolling.
  /// [horizontalScrollbarController]: The controller for the horizontal scrollbar.
  final Widget Function(
    BuildContext context,
    ScrollController verticalDataController,
    ScrollController verticalScrollbarController,
    ScrollController horizontalMainController,
    ScrollController horizontalScrollbarController,
  ) builder;

  @override
  State<SyncedScrollControllers> createState() =>
      _SyncedScrollControllersState();
}

class _SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _verticalDataController; // 메인 수직 (데이터 영역)
  late ScrollController _verticalScrollbarController; // 수직 스크롤바
  ScrollController? _horizontalMainController; // 메인 수평 (헤더 & 데이터 공통)
  late ScrollController _horizontalScrollbarController; // 수평 스크롤바

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
    _disposeOrUnsubscribe();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    // 수직 스크롤 컨트롤러 (메인 데이터 영역)
    _verticalDataController = widget.scrollController ?? ScrollController();

    // 수평 스크롤 컨트롤러 (헤더와 데이터 영역의 가로 스크롤 공통)
    _horizontalMainController = widget.horizontalScrollController ?? ScrollController();

    // 수직 스크롤바 컨트롤러
    _verticalScrollbarController = widget.verticalScrollbarController ??
        ScrollController(
          initialScrollOffset: _verticalDataController!.hasClients && _verticalDataController!.positions.isNotEmpty
              ? _verticalDataController!.offset
              : 0.0,
        );

    // 수평 스크롤바 컨트롤러
    _horizontalScrollbarController = widget.horizontalScrollbarController ??
        ScrollController(
          initialScrollOffset: _horizontalMainController!.hasClients && _horizontalMainController!.positions.isNotEmpty
              ? _horizontalMainController!.offset
              : 0.0,
        );

    // 각 쌍의 컨트롤러를 동기화합니다.
    _syncScrollControllers(_verticalDataController!, _verticalScrollbarController);
    _syncScrollControllers(_horizontalMainController!, _horizontalScrollbarController);
  }

  void _disposeOrUnsubscribe() {
    // 모든 리스너 제거
    _listenersMap.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listenersMap.clear();

    // 위젯에서 제공된 컨트롤러가 아니면 직접 dispose
    if (widget.scrollController == null) _verticalDataController?.dispose();
    if (widget.horizontalScrollController == null) _horizontalMainController?.dispose();
    if (widget.verticalScrollbarController == null) _verticalScrollbarController.dispose();
    if (widget.horizontalScrollbarController == null) _horizontalScrollbarController.dispose();
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

    // Check if slave position is valid and within bounds
    if (slave.position.outOfRange || slave.position.maxScrollExtent < 0) {
      return;
    }

    // Prevent cascading jumps
    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;

      // Calculate target offset, ensuring it's within valid bounds
      final targetOffset = master.offset.clamp(
        0.0,
        slave.position.maxScrollExtent,
      );

      // Only jump if there's a significant difference to avoid micro-jumps
      if ((slave.offset - targetOffset).abs() > 0.1) {
        slave.jumpTo(targetOffset);
      }
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _verticalDataController!,
        _verticalScrollbarController,
        _horizontalMainController!,
        _horizontalScrollbarController,
      );
}
