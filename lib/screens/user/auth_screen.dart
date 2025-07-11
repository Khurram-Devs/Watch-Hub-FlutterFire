import 'package:flutter/material.dart';
import 'package:watch_hub_ep/widgets/auth_screen_widget/login_form.dart';
import 'package:watch_hub_ep/widgets/auth_screen_widget/signup_form.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/footer_widget.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showForgotPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        screenWidth > 900
            ? 500
            : screenWidth > 600
            ? 600
            : double.infinity;

    return Scaffold(
      drawer: const NavDrawer(),
      appBar: const AppHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: cardWidth.toDouble(),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: theme.colorScheme.secondary,
                        labelColor: theme.colorScheme.secondary,
                        unselectedLabelColor: theme.unselectedWidgetColor,
                        labelStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
                      ),
                      const SizedBox(height: 24),

                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 400,
                          maxHeight: 700,
                        ),
                        child: SizedBox(
                          height: 500,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              LoginForm(
                                onForgotPassword: () {
                                  setState(() {
                                    _showForgotPassword = true;
                                  });
                                },
                              ),
                              const SignupForm(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
              const FooterWidget(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
