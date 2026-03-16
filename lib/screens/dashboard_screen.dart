import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> habits = [];
  int streak = 0;
  int totalCompletions = 0;

  static const bgColor = Color(0xFF080810);
  static const cardColor = Color(0xFF12121E);
  static const purpleColor = Color(0xFF7C5CFC);
  static const textMuted = Color(0xFF6B6B8A);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> loadData() async {
    if (userId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
      if (doc.exists) {
        setState(() {
          habits = List<Map<String, dynamic>>.from(
            doc.data()?['habits'] ?? []);
          streak = doc.data()?['streak'] ?? 0;
          totalCompletions = doc.data()?['totalCompletions'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int getCompleted() => habits.where((h) =>
    (h['completedCount'] ?? 0) >= (h['frequency'] ?? 1)).length;

  int getPercent() {
    if (habits.isEmpty) return 0;
    return ((getCompleted() / habits.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final completed = getCompleted();
    final percent = getPercent();
    final remaining = habits.length - completed;

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

                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getFormattedDate(),
                          style: GoogleFonts.inter(
                            fontSize: 12, color: textMuted),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                            color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text('$streak day streak',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C5CFC), Color(0xFF9D7DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${getGreeting()},',
                              style: GoogleFonts.inter(
                                fontSize: 14, color: Colors.white70)),
                            Text(widget.userName,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              habits.isEmpty
                                ? 'Add some habits to get started!'
                                : completed == habits.length
                                  ? 'All habits done! Amazing! 🎉'
                                  : '$remaining habit${remaining != 1 ? "s" : ""} remaining today',
                              style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Text('🌟',
                        style: TextStyle(fontSize: 40)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _statCard('Total Habits', '${habits.length}',
                      Icons.checklist, const Color(0xFF7C5CFC)),
                    _statCard('Completed', '$completed',
                      Icons.check_circle_outline,
                      const Color(0xFF4ADE80)),
                    _statCard('Day Streak', '$streak',
                      Icons.local_fire_department,
                      const Color(0xFFFB923C)),
                    _statCard("Today's Rate", '$percent%',
                      Icons.percent, const Color(0xFF38BDF8)),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress Card
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Today's Progress",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text('$percent%',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: purpleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            purpleColor),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        percent == 0
                          ? 'Add some habits to get started!'
                          : percent < 50
                            ? 'Good start! Keep going! 🚀'
                            : percent < 100
                              ? 'Halfway there! Amazing work! ⭐'
                              : '🎉 All habits completed! You are a champion!',
                        style: GoogleFonts.inter(
                          fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Today's Habits Preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Habits",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text('${habits.length} total',
                      style: GoogleFonts.inter(
                        fontSize: 12, color: textMuted)),
                  ],
                ),

                const SizedBox(height: 12),

                habits.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.eco_outlined,
                              color: textMuted, size: 40),
                            const SizedBox(height: 10),
                            Text('No habits yet!',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text('Go to My Habits to add some',
                              style: GoogleFonts.inter(
                                color: textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: habits.take(5)
                        .map((habit) => _habitPreviewItem(habit))
                        .toList(),
                    ),

                const SizedBox(height: 20),

                // Footer
                Center(
                  child: Text(
                    'Made with 💜 by Dipti Choubey',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: textMuted),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value,
    IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(label,
                style: GoogleFonts.inter(
                  fontSize: 11, color: textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _habitPreviewItem(Map<String, dynamic> habit) {
    final isDone = (habit['completedCount'] ?? 0) >=
      (habit['frequency'] ?? 1);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
            ? purpleColor.withOpacity(0.3)
            : Colors.white10),
      ),
      child: Row(
        children: [
          Text(habit['icon'] ?? '💧',
            style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(habit['name'] ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDone ? textMuted : Colors.white,
                decoration: isDone
                  ? TextDecoration.lineThrough
                  : null,
              ),
            ),
          ),
          if (isDone)
            const Icon(Icons.check_circle,
              color: Color(0xFF4ADE80), size: 20)
          else
            Text(
              '${habit['completedCount'] ?? 0}/${habit['frequency'] ?? 1}',
              style: GoogleFonts.inter(
                fontSize: 12, color: textMuted)),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = ['Sunday','Monday','Tuesday','Wednesday',
      'Thursday','Friday','Saturday'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }
}