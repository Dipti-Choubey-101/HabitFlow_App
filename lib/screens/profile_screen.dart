import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  const ProfileScreen({super.key, required this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> habits = [];
  int streak = 0;
  int totalCompletions = 0;
  int activeDays = 0;
  String userName = '';
  final nameController = TextEditingController();

  static const bgColor = Color(0xFF080810);
  static const cardColor = Color(0xFF12121E);
  static const purpleColor = Color(0xFF7C5CFC);
  static const textMuted = Color(0xFF6B6B8A);

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    nameController.text = userName;
    loadData();
  }

  Future<void> loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

      if (doc.exists) {
        final data = doc.data()!;
        final habitsList = List<Map<String, dynamic>>.from(
          data['habits'] ?? []);
        setState(() {
          habits = habitsList;
          streak = data['streak'] ?? 0;
          totalCompletions = data['totalCompletions'] ?? 0;
          activeDays = data['activeDays'] ?? 0;
          userName = data['name'] ?? widget.userName;
          nameController.text = userName;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> saveName() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.updateDisplayName(newName);
    await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({'name': newName}, SetOptions(merge: true));

    setState(() => userName = newName);
    showSnack('✅ Name updated successfully!');
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> resetAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Reset All Data',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will delete ALL your habits and progress permanently!',
          style: GoogleFonts.inter(color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
              style: GoogleFonts.inter(color: textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset',
              style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'habits': [],
          'streak': 0,
          'totalCompletions': 0,
          'perfectDays': 0,
          'activeDays': 0,
        }, SetOptions(merge: true));

      setState(() {
        habits = [];
        streak = 0;
        totalCompletions = 0;
        activeDays = 0;
      });
      showSnack('🗑️ All data reset successfully!');
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: purpleColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  int getUnlocked() {
    int count = 0;
    if (habits.isNotEmpty) count++;
    if (habits.length >= 3) count++;
    if (streak >= 7) count++;
    if (totalCompletions >= 10) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? userName;

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
                Text('Profile',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Header
                Container(
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
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'D',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('Habit Enthusiast 🌟',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Flexible(
                                  child: _miniBadge('🔥 $streak streak'),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: _miniBadge(
                                    '🏆 ${getUnlocked()} badges'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Email info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined,
                        color: purpleColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(user?.email ?? 'No email',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Lifetime Stats
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
                      Text('Lifetime Stats',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2,
                        children: [
                          _statItem(Icons.checklist,
                            '${habits.length}', 'Total Habits',
                            const Color(0xFF7C5CFC)),
                          _statItem(Icons.check_circle_outline,
                            '$totalCompletions', 'Completions',
                            const Color(0xFF4ADE80)),
                          _statItem(Icons.local_fire_department,
                            '$streak', 'Best Streak',
                            const Color(0xFFFB923C)),
                          _statItem(Icons.calendar_today,
                            '$activeDays', 'Days Active',
                            const Color(0xFF38BDF8)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Settings
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
                      Text('Settings',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Display Name',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: TextField(
                                controller: nameController,
                                style: GoogleFonts.inter(
                                  color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  hintText: 'Your name',
                                  hintStyle: GoogleFonts.inter(
                                    color: textMuted),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: saveName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purpleColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            ),
                            child: Text('Save',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reset All Data',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text('Delete all habits and progress',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: resetAllData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                Colors.redAccent.withOpacity(0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Reset',
                              style: GoogleFonts.inter(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Logout',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text('Sign out of your account',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('🚪 Logout',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Made with 💜 by Dipti Choubey',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: textMuted),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Row(
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(label,
                style: GoogleFonts.inter(
                  fontSize: 10, color: textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}