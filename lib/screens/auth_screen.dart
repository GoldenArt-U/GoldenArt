import 'dart:ui';
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

  Widget _leftPanel() => Container(
        color: AppColors.dark,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Subtle burgundy gradient on left panel
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'GOLDEN\n',
                          style: AppTextStyles.heading1
                              .copyWith(color: Colors.white, letterSpacing: 4)),
                      TextSpan(
                          text: 'ART',
                          style: AppTextStyles.heading1.copyWith(
                              color: AppColors.primary, letterSpacing: 8)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Container(width: 40, height: 2, color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.tagline.toUpperCase(),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textLight, letterSpacing: 2),
                  ),
                  const Spacer(),
                  Text(
                    '"L\'artisanat tunisien est\nune fenêtre sur l\'histoire."',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.textMedium,
                        fontStyle: FontStyle.italic,
                        height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _formPanel(AuthProvider auth) => Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text('Bienvenue', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text('Connectez-vous à votre compte GoldenArt.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 28),

              // Tab bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
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
                ),
              ),
              const SizedBox(height: 24),

              if (_tabController.index == 1) ...[
                TextField(
                  controller: _nameCtrl,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon:
                      Icon(Icons.lock_outline, color: AppColors.primary),
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

              if (auth.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(auth.error!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 12),
              ],

              ElevatedButton(
                onPressed: auth.loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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

              // Google sign-in
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.signInWithGoogle();
                  if (mounted && auth.isLoggedIn) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()));
                  }
                },
                icon: const Icon(Icons.g_mobiledata,
                    size: 28, color: Colors.white70),
                label: Text('Continuer avec Google',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white70)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),

              // Demo mode
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.signIn('demo@goldenart.tn', 'demo123');
                  if (mounted) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()));
                  }
                },
                icon: Icon(Icons.bolt_rounded, color: AppColors.primary),
                label: Text('Tester en Mode Démo',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _tabController
                        .animateTo(_tabController.index == 0 ? 1 : 0);
                  }),
                  child: Text(
                    _tabController.index == 0
                        ? "Pas de compte ? S'inscrire"
                        : 'Déjà un compte ? Se connecter',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
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
            return Row(
              children: [
                Expanded(flex: 4, child: _leftPanel()),
                Expanded(flex: 6, child: _formPanel(auth)),
              ],
            );
          } else {
            return _formPanel(auth);
          }
        },
      ),
    );
  }
}
