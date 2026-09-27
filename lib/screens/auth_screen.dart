import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/screens/home_screen.dart';
import 'package:artisan_market/utils/constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    bool ok;
    if (_tabController.index == 0) {
      ok = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    } else {
      ok = await auth.signUp(
          _emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
    }
    if (ok && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: AppColors.primary, width: 2)),
      );

  Widget _leftPanel() => Container(
        color: AppColors.dark,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: 'GOLDEN\n',
                    style: AppTextStyles.heading1.copyWith(color: Colors.white, letterSpacing: 4)),
                TextSpan(
                    text: 'ART',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.primary, letterSpacing: 8)),
              ]),
            ),
            const SizedBox(height: 16),
            Container(width: 40, height: 2, color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              AppConstants.tagline.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF9CA3AF), letterSpacing: 2),
            ),
            const Spacer(),
            Text(
              '"L\'artisanat tunisien est\nune fenêtre sur l\'histoire."',
              style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                  height: 1.7),
            ),
          ],
        ),
      );

  Widget _rightPanel(AuthProvider auth) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text('Bienvenue', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text('Connectez-vous à votre compte GoldenArt.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 24),
              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMedium,
                  labelStyle: AppTextStyles.bodyMedium,
                  tabs: const [
                    Tab(text: 'Connexion'),
                    Tab(text: 'Inscription'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_tabController.index == 1) ...([
                TextField(
                    controller: _nameCtrl,
                    decoration: _inputDecor('Nom complet', Icons.person_outline)),
                const SizedBox(height: 12),
              ]),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecor('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: _inputDecor('Mot de passe', Icons.lock_outline)
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMedium),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (auth.error != null) ...([
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(auth.error!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 12),
              ]),
              ElevatedButton(
                onPressed: auth.loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  elevation: 0,
                ),
                child: auth.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _tabController.index == 0
                            ? 'Se connecter'
                            : 'Créer un compte',
                        style: AppTextStyles.button),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.signInWithGoogle();
                  if (mounted && auth.isLoggedIn) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()));
                  }
                },
                icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.black87),
                label: Text('Continuer avec Google',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.signIn('demo@goldenart.tn', 'demo123');
                  if (mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()));
                  }
                },
                icon: Icon(Icons.bolt_rounded, color: AppColors.primary),
                label: Text('Tester en Mode Démo',
                    style:
                        AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _tabController.animateTo(_tabController.index == 0 ? 1 : 0);
                  }),
                  child: Text(
                    _tabController.index == 0
                        ? "Pas de compte ? S'inscrire"
                        : 'Déjà un compte ? Se connecter',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            // Two-panel layout
            return Row(
              children: [
                Expanded(flex: 4, child: _leftPanel()),
                Expanded(flex: 6, child: _rightPanel(auth)),
              ],
            );
          } else {
            // Single panel (mobile)
            return _rightPanel(auth);
          }
        },
      ),
    );
  }
}
