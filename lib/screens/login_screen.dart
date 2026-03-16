import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool rememberMe = true;
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // Colors
  static const bgColor = Color(0xFF080810);
  static const cardColor = Color(0xFF12121E);
  static const purpleColor = Color(0xFF7C5CFC);
  static const textMuted = Color(0xFF6B6B8A);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // ── Get all users ──
  Future<Map<String, dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('habitflow_users') ?? '{}';
    final Map<String, dynamic> users = {};
    if (usersJson != '{}') {
      final parts = usersJson.replaceAll('{', '').replaceAll('}', '').split('||');
      for (final part in parts) {
        if (part.isEmpty) continue;
        final kv = part.split('::');
        if (kv.length == 3) {
          users[kv[0]] = {'name': kv[1], 'password': kv[2]};
        }
      }
    }
    return users;
  }

  // ── Save all users ──
  Future<void> saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    final parts = users.entries.map((e) =>
      '${e.key}::${e.value['name']}::${e.value['password']}'
    ).join('||');
    await prefs.setString('habitflow_users', '{$parts}');
  }

  // ── Handle Login ──
  Future<void> handleLogin() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      showSnack('⚠️ Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      showSnack('⚠️ Please enter your password');
      return;
    }

    setState(() => isLoading = true);
    final users = await getUsers();

    if (!users.containsKey(email)) {
      showSnack('❌ No account found. Please sign up first!');
      setState(() => isLoading = false);
      return;
    }
    if (users[email]['password'] != password) {
      showSnack('❌ Incorrect password. Please try again!');
      setState(() => isLoading = false);
      return;
    }

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);
    await prefs.setString('current_user_name', users[email]['name']);

    setState(() => isLoading = false);
    showSnack('✅ Welcome back, ${users[email]['name']}!');

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // ── Handle Signup ──
  Future<void> handleSignup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty) {
      showSnack('⚠️ Please enter your name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      showSnack('⚠️ Please enter a valid email');
      return;
    }
    if (password.length < 6) {
      showSnack('⚠️ Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      showSnack('⚠️ Passwords do not match');
      return;
    }

    setState(() => isLoading = true);
    final users = await getUsers();

    if (users.containsKey(email)) {
      showSnack('❌ Account already exists. Please login!');
      setState(() => isLoading = false);
      return;
    }

    users[email] = {'name': name, 'password': password};
    await saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);
    await prefs.setString('current_user_name', name);

    setState(() => isLoading = false);
    showSnack('🎉 Account created! Welcome, $name!');

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // ── Show snackbar message ──
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Logo ──
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: purpleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('H',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('HabitFlow',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Title ──
              Text(
                isLogin ? 'Welcome back! 👋' : 'Create account ✨',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin
                  ? 'Sign in to continue your habit journey'
                  : 'Start your habit journey today',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),

              const SizedBox(height: 32),

              // ── Tabs ──
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _tabButton('Sign In', isLogin, () => setState(() => isLogin = true)),
                    _tabButton('Sign Up', !isLogin, () => setState(() => isLogin = false)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Form Fields ──
              if (!isLogin) ...[
                _inputField('Full Name', nameController, Icons.person_outline, false),
                const SizedBox(height: 16),
              ],
              _inputField('Email Address', emailController, Icons.email_outlined, false),
              const SizedBox(height: 16),
              _passwordField('Password', passwordController, obscurePassword, () {
                setState(() => obscurePassword = !obscurePassword);
              }),
              const SizedBox(height: 16),
              if (!isLogin) ...[
                _passwordField('Confirm Password', confirmController, obscureConfirm, () {
                  setState(() => obscureConfirm = !obscureConfirm);
                }),
                const SizedBox(height: 16),
              ],

              // ── Remember Me (Login only) ──
              if (isLogin) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (v) => setState(() => rememberMe = v!),
                          activeColor: purpleColor,
                        ),
                        Text('Remember me',
                          style: GoogleFonts.inter(color: textMuted, fontSize: 13)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        final email = emailController.text.trim().toLowerCase();
                        if (email.isEmpty || !email.contains('@')) {
                          showSnack('💡 Enter your email first then tap Forgot Password');
                        } else {
                          showSnack('✅ Try the password you used when signing up!');
                        }
                      },
                      child: Text('Forgot password?',
                        style: GoogleFonts.inter(color: purpleColor, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : (isLogin ? handleLogin : handleSignup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpleColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isLogin ? 'Sign In' : 'Create Account',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Switch tab text ──
              Center(
                child: TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                      ? "Don't have an account? Sign up free"
                      : 'Already have an account? Sign in',
                    style: GoogleFonts.inter(
                      color: purpleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Button Widget ──
  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? purpleColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Input Field Widget ──
  Widget _inputField(String label, TextEditingController controller, IconData icon, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: textMuted, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Password Field Widget ──
  Widget _passwordField(String label, TextEditingController controller, bool obscure, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: textMuted, size: 20),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: textMuted, size: 20),
                onPressed: toggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}