import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// A reusable full-month calendar widget designed for Patient, Doctor, and Admin dashboards.
/// Provides month navigation, day headers (Sun-Sat), today highlighting,
/// selected date styling, event/appointment indicator dots, and single-date selection.
class UnifiedFullMonthCalendar extends StatefulWidget {
  final DateTime? initialSelectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final Map<DateTime, int>? eventCounts; // Map of Date (year, month, day) to event count
  final Set<DateTime>? highlightedDates;

  const UnifiedFullMonthCalendar({
    super.key,
    this.initialSelectedDate,
    this.onDateSelected,
    this.eventCounts,
    this.highlightedDates,
  });

  @override
  State<UnifiedFullMonthCalendar> createState() => _UnifiedFullMonthCalendarState();
}

class _UnifiedFullMonthCalendarState extends State<UnifiedFullMonthCalendar> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelectedDate ?? DateTime.now();
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _focusedMonth = DateTime(initial.year, initial.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7; // Sunday = 0, Mon = 1...

    // Calculate grid items
    // Previous month padding days
    final prevMonthLastDay = DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;
    final leadingDaysCount = firstWeekday;

    final totalGridCells = ((leadingDaysCount + daysInMonth) / 7).ceil() * 7;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderLight, width: 1),
            boxShadow: AppTheme.subtleShadowLight,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Month/Year & Nav Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                  ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppTheme.primaryNavy),
                    onPressed: _previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppTheme.primaryNavy),
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Days of Week Header: Sun | Mon | Tue | Wed | Thu | Fri | Sat
          Row(
            children: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLightSecondary,
                          ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              DateTime cellDate;
              bool isCurrentMonth = true;

              if (index < leadingDaysCount) {
                // Days from previous month
                final dayNum = prevMonthLastDay - (leadingDaysCount - 1 - index);
                cellDate = DateTime(_focusedMonth.year, _focusedMonth.month - 1, dayNum);
                isCurrentMonth = false;
              } else if (index >= leadingDaysCount + daysInMonth) {
                // Days from next month
                final dayNum = index - (leadingDaysCount + daysInMonth) + 1;
                cellDate = DateTime(_focusedMonth.year, _focusedMonth.month + 1, dayNum);
                isCurrentMonth = false;
              } else {
                // Days from current month
                final dayNum = index - leadingDaysCount + 1;
                cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              }

              final isToday = _isSameDay(cellDate, today);
              final isSelected = _isSameDay(cellDate, _selectedDate);

              // Check for events
              int eventCount = widget.eventCounts?[DateTime(cellDate.year, cellDate.month, cellDate.day)] ?? 0;
              bool isHighlighted = widget.highlightedDates?.any((d) => _isSameDay(d, cellDate)) ?? false;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = cellDate;
                    if (!isCurrentMonth) {
                      _focusedMonth = DateTime(cellDate.year, cellDate.month, 1);
                    }
                  });
                  widget.onDateSelected?.call(cellDate);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryTeal
                        : isToday
                            ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: AppTheme.primaryTeal, width: 1.5)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${cellDate.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isCurrentMonth
                                  ? AppTheme.primaryNavy
                                  : AppTheme.textLightDisabled,
                          ),
                      ),
                      if ((eventCount > 0 || isHighlighted) && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryTeal,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    )));
  }
}
