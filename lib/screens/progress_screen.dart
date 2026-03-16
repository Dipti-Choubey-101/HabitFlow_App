import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic> weeklyData = {};
  List<Map<String, dynamic>> habits = [];
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  static const bgColor = Color(0xFF080810);
  static const cardColor = Color(0xFF12121E);
  static const purpleColor = Color(0xFF7C5CFC);
  static const textMuted = Color(0xFF6B6B8A);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email') ?? 'guest';
    final weeklyJson = prefs.getString('weeklyData') ?? '{}';
    final habitsJson = prefs.getString('habits_$email') ?? '[]';
    setState(() {
      weeklyData = Map<String, dynamic>.from(jsonDecode(weeklyJson));
      habits = List<Map<String, dynamic>>.from(jsonDecode(habitsJson));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          color: purpleColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Weekly Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly Overview',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildWeeklyChart(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Monthly Calendar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly View',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                  currentMonth--;
                                  if (currentMonth < 1) {
                                    currentMonth = 12;
                                    currentYear--;
                                  }
                                }),
                                child: const Icon(Icons.chevron_left,
                                  color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_getMonthName(currentMonth)} $currentYear',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setState(() {
                                  currentMonth++;
                                  if (currentMonth > 12) {
                                    currentMonth = 1;
                                    currentYear++;
                                  }
                                }),
                                child: const Icon(Icons.chevron_right,
                                  color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCalendar(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Breakdown
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category Breakdown',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryBreakdown(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final today = DateTime.now();
    final List<Map<String, dynamic>> weekDays = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = weeklyData[key];
      final percent = data != null ? (data['percentage'] ?? 0) as int : 0;
      weekDays.add({
        'day': days[date.weekday % 7],
        'percent': percent,
        'isToday': i == 0,
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: weekDays.map((d) {
        final percent = d['percent'] as int;
        final isToday = d['isToday'] as bool;
        return Column(
          children: [
            Text('$percent%',
              style: GoogleFonts.inter(fontSize: 9, color: textMuted)),
            const SizedBox(height: 4),
            Container(
              width: 28,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 28,
                height: percent.toDouble(),
                decoration: BoxDecoration(
                  color: isToday ? purpleColor : purpleColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(d['day'],
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isToday ? purpleColor : textMuted,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCalendar() {
    final dayHeaders = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final firstDay = DateTime(currentYear, currentMonth, 1).weekday % 7;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayHeaders.map((d) => Expanded(
            child: Center(
              child: Text(d,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: firstDay + daysInMonth,
          itemBuilder: (_, index) {
            if (index < firstDay) return const SizedBox();
            final day = index - firstDay + 1;
            final key =
              '$currentYear-${currentMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
            final data = weeklyData[key];
            final percent = data != null ? (data['percentage'] ?? 0) as int : 0;
            final isToday = today.day == day &&
              today.month == currentMonth &&
              today.year == currentYear;

            Color cellColor = Colors.transparent;
            if (percent > 0 && percent < 40) cellColor = purpleColor.withOpacity(0.2);
            else if (percent >= 40 && percent < 70) cellColor = purpleColor.withOpacity(0.4);
            else if (percent >= 70 && percent < 100) cellColor = purpleColor.withOpacity(0.7);
            else if (percent == 100) cellColor = purpleColor;

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: cellColor,
                shape: BoxShape.circle,
                border: isToday
                  ? Border.all(color: purpleColor, width: 2)
                  : null,
              ),
              child: Center(
                child: Text('$day',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isToday
                      ? Colors.white
                      : percent > 0 ? Colors.white : textMuted,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(purpleColor.withOpacity(0.2), 'Low'),
            const SizedBox(width: 12),
            _legendItem(purpleColor.withOpacity(0.5), 'Medium'),
            const SizedBox(width: 12),
            _legendItem(purpleColor, 'Perfect'),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: textMuted)),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    if (habits.isEmpty) {
      return Center(
        child: Text('No habits yet!',
          style: GoogleFonts.inter(color: textMuted)),
      );
    }

    final Map<String, int> categories = {};
    for (final h in habits) {
      final cat = h['category'] as String;
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    final max = categories.values.reduce((a, b) => a > b ? a : b);
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((entry) {
        final percent = entry.value / max;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(entry.key,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(purpleColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${entry.value}',
                style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[month - 1];
  }
}