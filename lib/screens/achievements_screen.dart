import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Map<String, dynamic>> habits = [];
  int streak = 0;
  int totalCompletions = 0;
  int perfectDays = 0;
  String filter = 'all';

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
    final habitsJson = prefs.getString('habits_$email') ?? '[]';
    setState(() {
      habits = List<Map<String, dynamic>>.from(jsonDecode(habitsJson));
      streak = prefs.getInt('streak') ?? 0;
      totalCompletions = prefs.getInt('totalCompletions') ?? 0;
      perfectDays = prefs.getInt('perfectDays') ?? 0;
    });
  }

  List<Map<String, dynamic>> get achievements => [
    {'id': 'first_habit', 'emoji': '🌱', 'title': 'First Step', 'desc': 'Add your first habit', 'unlocked': habits.length >= 1},
    {'id': 'three_habits', 'emoji': '🌿', 'title': 'Growing', 'desc': 'Add 3 habits', 'unlocked': habits.length >= 3},
    {'id': 'five_habits', 'emoji': '⭐', 'title': 'Goal Setter', 'desc': 'Add 5 habits', 'unlocked': habits.length >= 5},
    {'id': 'ten_habits', 'emoji': '🔟', 'title': 'Habit Hoarder', 'desc': 'Add 10 habits', 'unlocked': habits.length >= 10},
    {'id': 'first_complete', 'emoji': '✅', 'title': 'Done Deal', 'desc': 'Complete your first habit', 'unlocked': habits.any((h) => (h['completedCount'] ?? 0) > 0)},
    {'id': 'five_complete', 'emoji': '💪', 'title': 'On a Roll', 'desc': 'Complete 5 habits total', 'unlocked': totalCompletions >= 5},
    {'id': 'twenty_complete', 'emoji': '🚀', 'title': 'Momentum', 'desc': 'Complete 20 habits total', 'unlocked': totalCompletions >= 20},
    {'id': 'fifty_complete', 'emoji': '💫', 'title': 'Half Century', 'desc': 'Complete 50 habits total', 'unlocked': totalCompletions >= 50},
    {'id': 'hundred_complete', 'emoji': '💯', 'title': 'Century Club', 'desc': 'Complete 100 habits total', 'unlocked': totalCompletions >= 100},
    {'id': 'all_complete', 'emoji': '🏆', 'title': 'Perfect Day', 'desc': 'Complete all habits in a day', 'unlocked': habits.isNotEmpty && habits.every((h) => (h['completedCount'] ?? 0) >= (h['frequency'] ?? 1))},
    {'id': 'streak_2', 'emoji': '🔥', 'title': 'Warming Up', 'desc': '2 day streak', 'unlocked': streak >= 2},
    {'id': 'streak_3', 'emoji': '🔥🔥', 'title': 'On Fire', 'desc': '3 day streak', 'unlocked': streak >= 3},
    {'id': 'streak_7', 'emoji': '💫', 'title': 'Week Warrior', 'desc': '7 day streak', 'unlocked': streak >= 7},
    {'id': 'streak_14', 'emoji': '⚡', 'title': 'Two Weeks Strong', 'desc': '14 day streak', 'unlocked': streak >= 14},
    {'id': 'streak_30', 'emoji': '🌙', 'title': 'Monthly Master', 'desc': '30 day streak', 'unlocked': streak >= 30},
    {'id': 'health_habit', 'emoji': '💪', 'title': 'Health First', 'desc': 'Add a health habit', 'unlocked': habits.any((h) => h['category'].toString().contains('Health'))},
    {'id': 'mind_habit', 'emoji': '🧠', 'title': 'Mind Power', 'desc': 'Add a mind habit', 'unlocked': habits.any((h) => h['category'].toString().contains('Mind'))},
    {'id': 'work_habit', 'emoji': '💼', 'title': 'Work Mode', 'desc': 'Add a work habit', 'unlocked': habits.any((h) => h['category'].toString().contains('Work'))},
    {'id': 'fitness_habit', 'emoji': '🏃', 'title': 'Fitness Freak', 'desc': 'Add a fitness habit', 'unlocked': habits.any((h) => h['category'].toString().contains('Fitness'))},
    {'id': 'sleep_habit', 'emoji': '😴', 'title': 'Sleep Well', 'desc': 'Add a sleep habit', 'unlocked': habits.any((h) => h['category'].toString().contains('Sleep'))},
    {'id': 'morning_habit', 'emoji': '🌅', 'title': 'Early Bird', 'desc': 'Add a morning habit', 'unlocked': habits.any((h) => h['timeOfDay'] == 'morning')},
    {'id': 'evening_habit', 'emoji': '🌙', 'title': 'Night Owl', 'desc': 'Add an evening habit', 'unlocked': habits.any((h) => h['timeOfDay'] == 'evening')},
    {'id': 'freq_3', 'emoji': '🔁', 'title': 'Repeat It', 'desc': 'Frequency 3+', 'unlocked': habits.any((h) => (h['frequency'] ?? 1) >= 3)},
    {'id': 'freq_5', 'emoji': '🔄', 'title': 'High Freq', 'desc': 'Frequency 5+', 'unlocked': habits.any((h) => (h['frequency'] ?? 1) >= 5)},
    {'id': 'progress_50', 'emoji': '📊', 'title': 'Halfway', 'desc': 'Reach 50% progress', 'unlocked': _getDailyPercent() >= 50},
    {'id': 'progress_100', 'emoji': '🎯', 'title': 'Bullseye', 'desc': 'Reach 100% progress', 'unlocked': _getDailyPercent() == 100},
    {'id': 'three_perfect', 'emoji': '🌟', 'title': 'Hat Trick', 'desc': '3 perfect days', 'unlocked': perfectDays >= 3},
    {'id': 'seven_perfect', 'emoji': '💎', 'title': 'Diamond Week', 'desc': '7 perfect days', 'unlocked': perfectDays >= 7},
    {'id': 'color_used', 'emoji': '🎨', 'title': 'Colorful', 'desc': 'Use a custom color', 'unlocked': habits.any((h) => h['color'] != '#9D7DFF')},
    {'id': 'all_colors', 'emoji': '🌈', 'title': 'Rainbow', 'desc': 'Use 4 different colors', 'unlocked': habits.map((h) => h['color']).toSet().length >= 4},
    {'id': 'habit_15', 'emoji': '🎪', 'title': 'Overachiever', 'desc': 'Add 15 habits', 'unlocked': habits.length >= 15},
    {'id': 'habit_20', 'emoji': '🎭', 'title': 'Habit Collector', 'desc': 'Add 20 habits', 'unlocked': habits.length >= 20},
    {'id': 'all_categories', 'emoji': '🌍', 'title': 'Well Rounded', 'desc': 'Habits in 5 categories', 'unlocked': habits.map((h) => h['category']).toSet().length >= 5},
    {'id': 'streak_60', 'emoji': '🏅', 'title': 'Elite Streak', 'desc': '60 day streak', 'unlocked': streak >= 60},
    {'id': 'streak_100', 'emoji': '👑', 'title': 'Habit Royalty', 'desc': '100 day streak', 'unlocked': streak >= 100},
    {'id': 'completions_500', 'emoji': '🚀', 'title': '500 Club', 'desc': '500 completions', 'unlocked': totalCompletions >= 500},
    {'id': 'perfect_month', 'emoji': '🌠', 'title': 'Perfect Month', 'desc': '30 perfect days', 'unlocked': perfectDays >= 30},
  ];

  int _getDailyPercent() {
    if (habits.isEmpty) return 0;
    final done = habits.where((h) => (h['completedCount'] ?? 0) >= (h['frequency'] ?? 1)).length;
    return ((done / habits.length) * 100).round();
  }

  List<Map<String, dynamic>> get filteredAchievements {
    if (filter == 'unlocked') return achievements.where((a) => a['unlocked'] == true).toList();
    if (filter == 'locked') return achievements.where((a) => a['unlocked'] == false).toList();
    return achievements;
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a['unlocked'] == true).length;
    final total = achievements.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          color: purpleColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Achievements',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$unlocked / $total Unlocked',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: purpleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: total > 0 ? unlocked / total : 0,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(purpleColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _filterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _filterChip('Unlocked', 'unlocked'),
                          const SizedBox(width: 8),
                          _filterChip('Locked', 'locked'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _achievementCard(filteredAchievements[i]),
                    childCount: filteredAchievements.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = filter == value;
    return GestureDetector(
      onTap: () => setState(() => filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? purpleColor : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? purpleColor : Colors.white10),
        ),
        child: Text(label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : textMuted,
          ),
        ),
      ),
    );
  }

  Widget _achievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] == true;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? purpleColor.withOpacity(0.5) : Colors.white10,
        ),
        gradient: isUnlocked ? LinearGradient(
          colors: [purpleColor.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isUnlocked ? achievement['emoji'] : '🔒',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(achievement['title'],
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? Colors.white : textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(achievement['desc'],
            style: GoogleFonts.inter(fontSize: 9, color: textMuted),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}