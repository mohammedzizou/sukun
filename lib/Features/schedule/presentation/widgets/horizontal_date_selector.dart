import 'package:flutter/material.dart';
import 'package:prayer_silence_time_app/core/constants/theme_data.dart';
import 'package:intl/intl.dart';

class HorizontalDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const HorizontalDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dates: 3 days before, today, 3 days after
    final today = DateTime.now();
    final dates = List.generate(
      7,
      (index) =>
          today.subtract(const Duration(days: 3)).add(Duration(days: index)),
    );

    // Month Year Header (e.g. Mar 2026)
    final monthYear = DateFormat('MMM yyyy').format(selectedDate);

    return Container(
      width: double.infinity,
      height: 138.51,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(
        top: 16.52,
        left: 12.52,
        right: 12.52,
        bottom: 0.52,
      ),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.52, color: Color(0x16A3F7BF)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Text
          Text(
            monthYear,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0x99A3F7BF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.50,
            ),
          ),
          const SizedBox(height: 14),
          // Dates Row
          SizedBox(
            height: 73.47,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dates.length, (index) {
                final date = dates[index];
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;

                final isToday =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    behavior: HitTestBehavior.opaque,
                    child: _DateTile(
                      date: date,
                      isSelected: isSelected,
                      isToday: isToday,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;

  const _DateTile({
    required this.date,
    required this.isSelected,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('E').format(date); // Mon, Tue, Wed
    final dayNumber = date.day.toString(); // 1, 2, 3

    // Determine Container Decoration based on state
    Decoration? boxDecoration;
    if (isSelected) {
      boxDecoration = ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.00, 0.00),
          end: Alignment(1.00, 1.00),
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        shadows: const [
          BoxShadow(
            color: Color(0x4C2ECC71),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      );
    } else if (isToday) {
      boxDecoration = ShapeDecoration(
        color: const Color(0x192ECC71),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
    } else {
      boxDecoration = ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
    }

    return Container(
      height: 73.47,
      padding: EdgeInsets.only(top: 10, bottom: isToday ? 10 : 19.98),
      decoration: boxDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.80)
                  : (isToday
                        ? const Color(0xFF2ECC71)
                        : const Color(0x66A3F7BF)),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(height: 5.99),
          Text(
            dayNumber,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected || isToday
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.70),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
          if (isToday && !isSelected) ...[
            const Spacer(),
            Container(
              width: 4,
              height: 4,
              decoration: ShapeDecoration(
                color: const Color(0xFF2ECC71),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
