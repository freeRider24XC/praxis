import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/todo/quick_add_modal.dart';

/// 支持多视图切换的日程模块
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

enum ScheduleViewMode { day, twoDay, threeDay, week, month, agenda }

enum _DragType { move, resizeTop, resizeBottom }

class _EventLayout {
  final int startMinutes;
  final int durationMinutes;

  const _EventLayout({
    required this.startMinutes,
    required this.durationMinutes,
  });
}

class _ScheduleEvent {
  final Todo todo;
  final DateTime date;
  final DateTime? start;
  final DateTime? end;

  const _ScheduleEvent({
    required this.todo,
    required this.date,
    this.start,
    this.end,
  });

  bool get isAllDay => start == null;

  String get timeLabel {
    if (isAllDay) return '全天';
    final startLabel = '${start!.hour.toString().padLeft(2, '0')}:${start!.minute.toString().padLeft(2, '0')}';
    if (end == null) return startLabel;
    final endLabel = '${end!.hour.toString().padLeft(2, '0')}:${end!.minute.toString().padLeft(2, '0')}';
    return '$startLabel - $endLabel';
  }
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentDate = DateUtils.dateOnly(DateTime.now());
  ScheduleViewMode _viewMode = ScheduleViewMode.week;

  final Map<DateTime, List<_ScheduleEvent>> _eventsByDate = {};
  final Map<String, _EventLayout> _pendingLayouts = {};

  static const int _slotMinutes = 15;
  static const double _slotHeight = 22.0;
  static const double _allDaySectionHeight = 72.0;
  static const int _minutesPerDay = 24 * 60;
  static const int _totalSlots = _minutesPerDay ~/ _slotMinutes;
  double get _timelineHeight => _totalSlots * _slotHeight;

  String? _draggingEventId;
  _DragType? _dragType;
  double _dragStartGlobalY = 0;
  int _dragOriginalStart = 0;
  int _dragOriginalDuration = 60;
  DateTime? _draggingDate;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final todos = DatabaseService.getAllTodos().where((todo) => !todo.isDone && (todo.dueDate != null || todo.reminderTime != null)).toList();
    final map = <DateTime, List<_ScheduleEvent>>{};

    for (final todo in todos) {
      final event = _buildEvent(todo);
      if (event == null) continue;
      map.putIfAbsent(event.date, () => []).add(event);
    }

    for (final entry in map.entries) {
      entry.value.sort((a, b) {
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;
        if (a.isAllDay && b.isAllDay) return a.todo.createdAt.compareTo(b.todo.createdAt);
        return a.start!.compareTo(b.start!);
      });
    }

    setState(() {
      _pendingLayouts.clear();
      _eventsByDate
        ..clear()
        ..addAll(map);
    });
  }

  _ScheduleEvent? _buildEvent(Todo todo) {
    final reminder = todo.reminderTime;
    final due = todo.dueDate;
    final base = reminder ?? due;
    if (base == null) return null;
    final date = DateUtils.dateOnly(base);
    final hasTime = reminder != null || (due != null && (due.hour != 0 || due.minute != 0));

    if (!hasTime) {
      return _ScheduleEvent(todo: todo, date: date);
    }

    final start = reminder ?? due!;
    DateTime? end;
    if (reminder != null && due != null && due.isAfter(reminder)) {
      end = due;
    } else if (reminder == null && due != null && (due.hour != 0 || due.minute != 0)) {
      end = due.add(const Duration(minutes: 60));
    }

    end ??= start.add(const Duration(minutes: 60));

    return _ScheduleEvent(todo: todo, date: date, start: start, end: end);
  }

  List<_ScheduleEvent> _eventsForDate(DateTime date) {
    return _eventsByDate[DateUtils.dateOnly(date)] ?? [];
  }

  void _changeView(ScheduleViewMode mode) {
    setState(() => _viewMode = mode);
  }

  void _goToToday() {
    setState(() => _currentDate = DateUtils.dateOnly(DateTime.now()));
  }

  void _shiftDays(int days) {
    setState(() => _currentDate = DateUtils.dateOnly(_currentDate.add(Duration(days: days))));
  }

  void _shiftMonths(int months) {
    setState(() => _currentDate = DateTime(_currentDate.year, _currentDate.month + months, 1));
  }

  void _onBack() {
    switch (_viewMode) {
      case ScheduleViewMode.day:
        _shiftDays(-1);
        break;
      case ScheduleViewMode.twoDay:
        _shiftDays(-2);
        break;
      case ScheduleViewMode.threeDay:
        _shiftDays(-3);
        break;
      case ScheduleViewMode.week:
      case ScheduleViewMode.agenda:
        _shiftDays(-7);
        break;
      case ScheduleViewMode.month:
        _shiftMonths(-1);
        break;
    }
  }

  void _onForward() {
    switch (_viewMode) {
      case ScheduleViewMode.day:
        _shiftDays(1);
        break;
      case ScheduleViewMode.twoDay:
        _shiftDays(2);
        break;
      case ScheduleViewMode.threeDay:
        _shiftDays(3);
        break;
      case ScheduleViewMode.week:
      case ScheduleViewMode.agenda:
        _shiftDays(7);
        break;
      case ScheduleViewMode.month:
        _shiftMonths(1);
        break;
    }
  }

  String _headerText() {
    switch (_viewMode) {
      case ScheduleViewMode.day:
        return '${_currentDate.year}年${_currentDate.month}月${_currentDate.day}日';
      case ScheduleViewMode.twoDay:
      case ScheduleViewMode.threeDay:
      case ScheduleViewMode.week:
        final end = _currentDate.add(Duration(
            days: _viewMode == ScheduleViewMode.twoDay
                ? 1
                : _viewMode == ScheduleViewMode.threeDay
                    ? 2
                    : 6));
        return '${_currentDate.month}.${_currentDate.day} - ${end.month}.${end.day}';
      case ScheduleViewMode.month:
        return '${_currentDate.year}年${_currentDate.month}月';
      case ScheduleViewMode.agenda:
        return '任务列表';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? DesignTokens.backgroundDark : Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing6,
              vertical: DesignTokens.spacing2,
            ),
            decoration: BoxDecoration(
              color: isDark ? DesignTokens.backgroundDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _headerText(),
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeHeadlineSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _onBack,
                          icon: Icon(
                            Icons.chevron_left,
                            color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
                          ),
                        ),
                        IconButton(
                          onPressed: _onForward,
                          icon: Icon(
                            Icons.chevron_right,
                            color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: _goToToday,
                          child: const Text('今天'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing2),
                _buildViewSwitcher(),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildViewContent(isDark),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const QuickAddModal(),
          );
          _loadEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildViewSwitcher() {
    Widget chip(String label, ScheduleViewMode mode) {
      final selected = _viewMode == mode;
      return Padding(
        padding: const EdgeInsets.only(right: DesignTokens.spacing2),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => _changeView(mode),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('日', ScheduleViewMode.day),
          chip('双日', ScheduleViewMode.twoDay),
          chip('三日', ScheduleViewMode.threeDay),
          chip('周', ScheduleViewMode.week),
          chip('月', ScheduleViewMode.month),
          chip('列表', ScheduleViewMode.agenda),
        ],
      ),
    );
  }

  Widget _buildViewContent(bool isDark) {
    switch (_viewMode) {
      case ScheduleViewMode.day:
        return _buildMultiDayView(1, isDark);
      case ScheduleViewMode.twoDay:
        return _buildMultiDayView(2, isDark);
      case ScheduleViewMode.threeDay:
        return _buildMultiDayView(3, isDark);
      case ScheduleViewMode.week:
        return _buildMultiDayView(7, isDark);
      case ScheduleViewMode.month:
        return _buildMonthView(isDark);
      case ScheduleViewMode.agenda:
        return _buildAgendaView(isDark);
    }
  }

  Widget _buildMultiDayView(int dayCount, bool isDark) {
    final dates = List.generate(dayCount, (i) => DateUtils.dateOnly(_currentDate.add(Duration(days: i))));
    final config = _resolveLayoutConfig(dayCount);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - config.timeColumnWidth - DesignTokens.spacing2;
        final spacingTotal = config.cardSpacing * (dayCount - 1);
        final columnWidth = (availableWidth - spacingTotal) / dayCount;
        final content = SizedBox(
          height: _allDaySectionHeight + _timelineHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeAxis(isDark, config),
              const SizedBox(width: DesignTokens.spacing2),
              ...dates.asMap().entries.map(
                    (entry) => SizedBox(
                      width: columnWidth,
                      child: _buildTimelineColumn(
                        entry.value,
                        isDark,
                        config,
                        isLast: entry.key == dates.length - 1,
                      ),
                    ),
                  ),
            ],
          ),
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildTimelineColumn(
    DateTime date,
    bool isDark,
    _TimelineLayoutConfig config, {
    bool isLast = false,
  }) {
    final events = _eventsForDate(date);
    final allDay = events.where((e) => e.isAllDay).toList();
    final timed = events.where((e) => !e.isAllDay).toList();
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    return Container(
      margin: EdgeInsets.only(right: isLast ? 0 : config.cardSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${weekdays[date.weekday - 1]} ${date.month}/${date.day}',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall * config.fontScale,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing1),
          _buildAllDaySection(allDay, isDark, config),
          const SizedBox(height: DesignTokens.spacing2),
          SizedBox(
            height: _timelineHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: _buildTimelineGrid(isDark)),
                ...timed.map((event) => _buildTimedEvent(event, isDark, config)),
                if (timed.isEmpty)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: DesignTokens.spacing4),
                      child: Text(
                        '暂无时间段任务',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelSmall * config.fontScale,
                          color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDaySection(List<_ScheduleEvent> events, bool isDark, _TimelineLayoutConfig config) {
    if (events.isEmpty) {
      return SizedBox(
        height: _allDaySectionHeight,
        child: Center(
          child: Text(
            '全天任务',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall * config.fontScale,
              color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    return Container(
      height: _allDaySectionHeight,
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: Border.all(color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: events
              .map(
                (event) => Padding(
                  padding: EdgeInsets.only(right: config.cardSpacing),
                  child: _buildAllDayChip(event, isDark, config),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTimeAxis(bool isDark, _TimelineLayoutConfig config) {
    return SizedBox(
      width: config.timeColumnWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: _allDaySectionHeight),
          ...List.generate(_totalSlots + 1, (index) {
            final minutes = index * _slotMinutes;
            final shouldShow = minutes % 60 == 0 || minutes % 60 == 30;
            final label = _formatMinutes(minutes);
            return SizedBox(
              height: _slotHeight,
              child: shouldShow
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        label,
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelSmall * config.fontScale,
                          color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineGrid(bool isDark) {
    return Column(
      children: List.generate(_totalSlots, (index) {
        final minutes = index * _slotMinutes;
        final isHour = minutes % 60 == 0;
        final isHalf = minutes % 60 == 30;
        Color lineColor;
        if (isHour) {
          lineColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08);
        } else if (isHalf) {
          lineColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04);
        } else {
          lineColor = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02);
        }
        return Container(
          height: _slotHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: lineColor,
                width: isHour ? 1.0 : 0.5,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimedEvent(_ScheduleEvent event, bool isDark, _TimelineLayoutConfig config) {
    if (event.start == null) return const SizedBox.shrink();
    final layout = _layoutForEvent(event);
    final top = _minutesToPixels(layout.startMinutes);
    final height = math.max(_minutesToPixels(layout.durationMinutes), _slotHeight);

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      height: height,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) => _startDrag(event, details, _DragType.move),
            onPanUpdate: _updateDrag,
            onPanEnd: (_) => _endDrag(),
            child: _buildEventCard(event, isDark, config, durationMinutes: layout.durationMinutes),
          ),
          _buildResizeHandle(event, isDark, isTop: true),
          _buildResizeHandle(event, isDark, isTop: false),
        ],
      ),
    );
  }

  Widget _buildResizeHandle(_ScheduleEvent event, bool isDark, {required bool isTop}) {
    return Positioned(
      top: isTop ? -6 : null,
      bottom: isTop ? null : -6,
      left: 0,
      right: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) => _startDrag(event, details, isTop ? _DragType.resizeTop : _DragType.resizeBottom),
        onPanUpdate: _updateDrag,
        onPanEnd: (_) => _endDrag(),
        child: Center(
          child: Container(
            width: 32,
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllDayChip(
    _ScheduleEvent event,
    bool isDark,
    _TimelineLayoutConfig config,
  ) {
    return GestureDetector(
      onTap: () => _openTodo(event.todo),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config.cardPadding,
          vertical: DesignTokens.spacing2,
        ),
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: _priorityColor(event.todo.priority)),
        ),
        child: Text(
          event.todo.title,
          style: DesignTokens.textStyle(
            fontSize: DesignTokens.fontSizeLabelSmall * config.fontScale,
            fontWeight: DesignTokens.fontWeightMedium,
            color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
    _ScheduleEvent event,
    bool isDark,
    _TimelineLayoutConfig config, {
    int? durationMinutes,
  }) {
    final todo = event.todo;
    return GestureDetector(
      onTap: () => _openTodo(todo),
      child: Container(
        margin: EdgeInsets.only(bottom: config.cardSpacing),
        padding: EdgeInsets.all(config.cardPadding),
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: _priorityColor(todo.priority), width: 1),
          boxShadow: DesignTokens.shadowSmall,
        ),
        child: Text(
          todo.title,
          style: DesignTokens.textStyle(
            fontSize: DesignTokens.fontSizeBodySmall * config.fontScale,
            fontWeight: DesignTokens.fontWeightMedium,
            color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthView(bool isDark) {
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final startOffset = firstDay.weekday - 1;
    final startDate = firstDay.subtract(Duration(days: startOffset));

    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: DesignTokens.spacing2,
            mainAxisSpacing: DesignTokens.spacing2,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final date = DateUtils.dateOnly(startDate.add(Duration(days: index)));
            final isCurrentMonth = date.month == _currentDate.month;
            final events = _eventsForDate(date);
            return GestureDetector(
              onTap: () => setState(() => _currentDate = date),
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: date == DateUtils.dateOnly(DateTime.now())
                      ? DesignTokens.primaryColor.withOpacity(0.08)
                      : (isDark ? DesignTokens.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  border: Border.all(
                    color: date == _currentDate ? DesignTokens.primaryColor : (isDark ? DesignTokens.borderDark : DesignTokens.borderLight),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeLabelSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isCurrentMonth
                            ? (isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight)
                            : (isDark ? DesignTokens.textTertiaryDark : DesignTokens.textTertiaryLight),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing1),
                    if (events.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: events.length > 3 ? 3 : events.length,
                          itemBuilder: (context, i) {
                            final event = events[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              height: 4,
                              decoration: BoxDecoration(
                                color: _priorityColor(event.todo.priority),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAgendaView(bool isDark) {
    final sortedDates = _eventsByDate.keys.toList()..sort();
    if (sortedDates.isEmpty) {
      return _buildEmptyHint(isDark);
    }
    final agendaConfig = _resolveLayoutConfig(1);

    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = _eventsForDate(date);
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spacing5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.year}.${date.month}.${date.day}',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing2),
              ...events.map((event) => _buildEventCard(event, isDark, agendaConfig)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyHint(bool isDark) {
    return Center(
      child: Text(
        '暂无任何任务，请先添加',
        style: DesignTokens.textStyle(
          fontSize: DesignTokens.fontSizeBodySmall,
          color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
        ),
      ),
    );
  }

  _EventLayout _layoutForEvent(_ScheduleEvent event) {
    final pending = _pendingLayouts[event.todo.id];
    if (pending != null) return pending;
    if (event.start == null) {
      return const _EventLayout(startMinutes: 0, durationMinutes: 60);
    }
    final startMinutes = _minutesSinceMidnight(event.start!);
    final end = event.end ?? event.start!.add(const Duration(minutes: 60));
    final rawDuration = end.difference(event.start!).inMinutes;
    final durationMinutes = math.max(_slotMinutes, rawDuration);
    final clampedDuration = math.min(durationMinutes, _minutesPerDay - startMinutes);
    return _EventLayout(
      startMinutes: startMinutes,
      durationMinutes: clampedDuration,
    );
  }

  int _minutesSinceMidnight(DateTime time) => time.hour * 60 + time.minute;

  double _minutesToPixels(int minutes) => (minutes / _slotMinutes) * _slotHeight;

  void _startDrag(_ScheduleEvent event, DragStartDetails details, _DragType type) {
    if (event.start == null) return;
    final layout = _layoutForEvent(event);
    setState(() {
      _draggingEventId = event.todo.id;
      _dragType = type;
      _dragStartGlobalY = details.globalPosition.dy;
      _dragOriginalStart = layout.startMinutes;
      _dragOriginalDuration = layout.durationMinutes;
      _draggingDate = event.date;
      _pendingLayouts[event.todo.id] = layout;
    });
  }

  void _updateDrag(DragUpdateDetails details) {
    if (_draggingEventId == null || _dragType == null) return;
    final delta = details.globalPosition.dy - _dragStartGlobalY;
    final deltaSlots = (delta / _slotHeight).round();
    int newStart = _dragOriginalStart;
    int newDuration = _dragOriginalDuration;

    switch (_dragType!) {
      case _DragType.move:
        newStart = _clampMinutes(
          _dragOriginalStart + deltaSlots * _slotMinutes,
          0,
          _minutesPerDay - _dragOriginalDuration,
        );
        break;
      case _DragType.resizeTop:
        final deltaMinutes = deltaSlots * _slotMinutes;
        final tentativeStart = _dragOriginalStart + deltaMinutes;
        final maxStart = _dragOriginalStart + _dragOriginalDuration - _slotMinutes;
        newStart = _clampMinutes(tentativeStart, 0, maxStart);
        newDuration = _dragOriginalDuration - (newStart - _dragOriginalStart);
        break;
      case _DragType.resizeBottom:
        final deltaMinutes = deltaSlots * _slotMinutes;
        newDuration = _clampMinutes(
          _dragOriginalDuration + deltaMinutes,
          _slotMinutes,
          _minutesPerDay - _dragOriginalStart,
        );
        break;
    }

    setState(() {
      _pendingLayouts[_draggingEventId!] = _EventLayout(
        startMinutes: newStart,
        durationMinutes: newDuration,
      );
    });
  }

  Future<void> _endDrag() async {
    if (_draggingEventId == null || _draggingDate == null) {
      _resetDragState();
      return;
    }
    final layout = _pendingLayouts[_draggingEventId!];
    if (layout == null) {
      _resetDragState();
      return;
    }
    await _applyLayoutToTodo(_draggingEventId!, _draggingDate!, layout);
    _resetDragState();
    await _loadEvents();
  }

  void _resetDragState() {
    _draggingEventId = null;
    _dragType = null;
    _dragStartGlobalY = 0;
    _dragOriginalStart = 0;
    _dragOriginalDuration = 60;
    _draggingDate = null;
  }

  Future<void> _applyLayoutToTodo(String todoId, DateTime date, _EventLayout layout) async {
    final todo = DatabaseService.getTodoById(todoId);
    if (todo == null) return;
    final dayStart = DateTime(date.year, date.month, date.day);
    final newStart = dayStart.add(Duration(minutes: layout.startMinutes));
    final newEnd = newStart.add(Duration(minutes: layout.durationMinutes));
    todo.reminderTime = newStart;
    todo.dueDate = newEnd;
    todo.updatedAt = DateTime.now();
    await DatabaseService.updateTodo(todo);
  }

  int _clampMinutes(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  String _formatMinutes(int minutes) {
    final total = _clampMinutes(minutes, 0, _minutesPerDay);
    final h = (total ~/ 60).toString().padLeft(2, '0');
    final m = (total % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  _TimelineLayoutConfig _resolveLayoutConfig(int dayCount) {
    if (dayCount <= 1) {
      return const _TimelineLayoutConfig(
        timeColumnWidth: 64,
        fontScale: 1.0,
        cardSpacing: DesignTokens.spacing3,
        cardPadding: DesignTokens.spacing4,
      );
    } else if (dayCount == 2) {
      return const _TimelineLayoutConfig(
        timeColumnWidth: 58,
        fontScale: 0.95,
        cardSpacing: DesignTokens.spacing3,
        cardPadding: DesignTokens.spacing3,
      );
    } else if (dayCount == 3) {
      return const _TimelineLayoutConfig(
        timeColumnWidth: 54,
        fontScale: 0.9,
        cardSpacing: DesignTokens.spacing2,
        cardPadding: DesignTokens.spacing3,
      );
    } else {
      return const _TimelineLayoutConfig(
        timeColumnWidth: 48,
        fontScale: 0.8,
        cardSpacing: DesignTokens.spacing2,
        cardPadding: DesignTokens.spacing2,
      );
    }
  }

  Color _priorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.urgent:
      case TodoPriority.high:
        return DesignTokens.primaryColor;
      case TodoPriority.medium:
        return DesignTokens.secondaryOrange;
      case TodoPriority.low:
        return DesignTokens.secondaryEmerald;
    }
  }

  void _openTodo(Todo todo) {
    Get.snackbar('任务详情', todo.title, snackPosition: SnackPosition.BOTTOM);
  }
}

class _TimelineLayoutConfig {
  final double timeColumnWidth;
  final double fontScale;
  final double cardSpacing;
  final double cardPadding;

  const _TimelineLayoutConfig({
    required this.timeColumnWidth,
    required this.fontScale,
    required this.cardSpacing,
    required this.cardPadding,
  });
}
