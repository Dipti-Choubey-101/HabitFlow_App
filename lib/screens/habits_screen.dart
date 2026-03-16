import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Map<String, dynamic>> habits = [];
  String currentFilter = 'all';
  String searchQuery = '';
  String userEmail = 'guest';

  final nameController = TextEditingController();
  String selectedCategory = '💪 Health';
  String selectedTime = 'morning';
  String selectedColor = '#9D7DFF';
  String selectedIcon = '💧';
  int frequency = 1;

  static const bgColor = Color(0xFF080810);
  static const cardColor = Color(0xFF12121E);
  static const purpleColor = Color(0xFF7C5CFC);
  static const textMuted = Color(0xFF6B6B8A);

  final categories = ['💪 Health','🧠 Mind','💼 Work','⭐ Personal','🏃 Fitness','🥗 Nutrition','😴 Sleep','👥 Social'];
  final times = ['morning','afternoon','evening','anytime'];
  final colors = ['#9D7DFF','#4ADE80','#38BDF8','#F472B6','#FB923C','#FACC15'];
  final icons = ['💧','🏃','📚','🧘','💊','🥗','😴','✍️'];

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('current_user_email') ?? 'guest';
    final habitsJson = prefs.getString('habits_$userEmail') ?? '[]';
    setState(() {
      habits = List<Map<String, dynamic>>.from(jsonDecode(habitsJson));
    });
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habits_$userEmail', jsonEncode(habits));
  }

  void addHabit() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showSnack('⚠️ Please enter a habit name!');
      return;
    }

    final newHabit = {
      'id': const Uuid().v4(),
      'name': name,
      'category': selectedCategory,
      'timeOfDay': selectedTime,
      'frequency': frequency,
      'completedCount': 0,
      'color': selectedColor,
      'icon': selectedIcon,
      'completed': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      habits.add(newHabit);
      nameController.clear();
      frequency = 1;
    });

    saveHabits();
    Navigator.pop(context);
    showSnack('✅ Habit added successfully!');
  }

  void toggleHabit(String id) {
    setState(() {
      habits = habits.map((h) {
        if (h['id'] == id) {
          final newCount = (h['completedCount'] ?? 0) < (h['frequency'] ?? 1)
            ? (h['completedCount'] ?? 0) + 1
            : 0;
          return {...h, 'completedCount': newCount, 'completed': newCount >= (h['frequency'] ?? 1)};
        }
        return h;
      }).toList();
    });
    saveHabits();
  }

  void deleteHabit(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Delete Habit',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this habit?',
          style: GoogleFonts.inter(color: textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: textMuted)),
          ),
          TextButton(
            onPressed: () {
              setState(() => habits.removeWhere((h) => h['id'] == id));
              saveHabits();
              Navigator.pop(context);
              showSnack('🗑️ Habit deleted!');
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: purpleColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add New Habit',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                Text('Habit Name', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g. Drink 8 glasses of water',
                      hintStyle: GoogleFonts.inter(color: textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Category', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    dropdownColor: cardColor,
                    style: GoogleFonts.inter(color: Colors.white),
                    underline: const SizedBox(),
                    items: categories.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setSheetState(() => selectedCategory = v!),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Time of Day', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  children: times.map((t) {
                    final labels = {
                      'morning': '🌅 Morning',
                      'afternoon': '☀️ Noon',
                      'evening': '🌙 Evening',
                      'anytime': '⏰ Any',
                    };
                    final isSelected = selectedTime == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedTime = t),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? purpleColor : bgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? purpleColor : Colors.white10),
                          ),
                          child: Center(
                            child: Text(labels[t]!,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isSelected ? Colors.white : textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text('Frequency (times per day)',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                        setSheetState(() => frequency = (frequency - 1).clamp(1, 10)),
                      icon: const Icon(Icons.remove_circle_outline, color: purpleColor),
                    ),
                    Text('$frequency',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                        setSheetState(() => frequency = (frequency + 1).clamp(1, 10)),
                      icon: const Icon(Icons.add_circle_outline, color: purpleColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Color', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  children: colors.map((c) {
                    final color = Color(int.parse('0xFF${c.substring(1)}'));
                    final isSelected = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedColor = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text('Icon', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  children: icons.map((i) {
                    final isSelected = selectedIcon == i;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedIcon = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? purpleColor : bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? purpleColor : Colors.white10),
                        ),
                        child: Center(
                          child: Text(i, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: addHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purpleColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Add Habit',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getFilteredHabits() {
    List<Map<String, dynamic>> filtered = [...habits];
    if (currentFilter == 'pending') {
      filtered = filtered.where((h) =>
        (h['completedCount'] ?? 0) < (h['frequency'] ?? 1)).toList();
    } else if (currentFilter == 'completed') {
      filtered = filtered.where((h) =>
        (h['completedCount'] ?? 0) >= (h['frequency'] ?? 1)).toList();
    } else if (currentFilter == 'morning') {
      filtered = filtered.where((h) => h['timeOfDay'] == 'morning').toList();
    } else if (currentFilter == 'evening') {
      filtered = filtered.where((h) => h['timeOfDay'] == 'evening').toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((h) =>
        h['name'].toString().toLowerCase().contains(searchQuery)).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredHabits();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Habits',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search habits...',
                        hintStyle: GoogleFonts.inter(color: textMuted),
                        prefixIcon: const Icon(Icons.search, color: textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', 'all'),
                        _filterChip('Pending', 'pending'),
                        _filterChip('Done', 'completed'),
                        _filterChip('🌅 Morning', 'morning'),
                        _filterChip('🌙 Evening', 'evening'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.list_alt_outlined, color: textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          searchQuery.isNotEmpty
                            ? 'No habits match your search'
                            : 'No habits here!',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'Tap + to add your first habit',
                          style: GoogleFonts.inter(color: textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _habitItem(filtered[i]),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddHabitSheet,
        backgroundColor: purpleColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = currentFilter == value;
    return GestureDetector(
      onTap: () => setState(() => currentFilter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

  Widget _habitItem(Map<String, dynamic> habit) {
    final isDone = (habit['completedCount'] ?? 0) >= (habit['frequency'] ?? 1);
    final color = Color(int.parse('0xFF${habit['color'].toString().substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? purpleColor.withOpacity(0.3) : Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(habit['icon'] ?? '💧', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit['name'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone ? textMuted : Colors.white,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: purpleColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(habit['category'] ?? '',
                        style: GoogleFonts.inter(fontSize: 10, color: purpleColor)),
                    ),
                    const SizedBox(width: 6),
                    Text('${habit['completedCount'] ?? 0}/${habit['frequency'] ?? 1}x',
                      style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => toggleHabit(habit['id']),
            icon: Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? const Color(0xFF4ADE80) : textMuted,
              size: 26,
            ),
          ),
          IconButton(
            onPressed: () => deleteHabit(habit['id']),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }
}