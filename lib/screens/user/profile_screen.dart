import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watch_hub_ep/models/user_model.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/footer_widget.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';
import 'package:watch_hub_ep/widgets/profile_screen_widget/addresses_tab.dart';
import 'package:watch_hub_ep/widgets/profile_screen_widget/orders_tab.dart';
import 'package:watch_hub_ep/widgets/profile_screen_widget/profile_tab.dart';
import 'package:watch_hub_ep/widgets/profile_screen_widget/wishlist_tab.dart';

class ProfileScreen extends StatefulWidget {
  final String tab;
  const ProfileScreen({super.key, required this.tab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  final ProfileService _srv = ProfileService();
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final avatarController = TextEditingController();

@override
void initState() {
  super.initState();
  _tc = TabController(length: 4, vsync: this);

  final initialIndex = switch (widget.tab.toLowerCase()) {
    'addressbook' => 1,
    'wishlist' => 2,
    'orders' => 3,
    _ => 0,
  };
  _tc.index = initialIndex;

  _profileSub = _srv.profileStream().listen((snap) {
    if (!snap.exists || !mounted) return;
    final user = UserModel.fromDoc(snap);
    setState(() {
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phone;
      avatarController.text = user.avatar;
    });
  });
}

late final StreamSubscription _profileSub;

@override
void dispose() {
  _profileSub.cancel();
  _tc.dispose();
  nameController.dispose();
  emailController.dispose();
  phoneController.dispose();
  avatarController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppHeader(),
      drawer: const NavDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tc,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: theme.colorScheme.secondary.withOpacity(0.15),
                      ),
                      labelColor: theme.colorScheme.secondary,
                      unselectedLabelColor: theme.textTheme.bodySmall?.color,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      tabs: const [
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Profile'),
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Address Book'),
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Wishlist'),
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Orders'),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 600,
                      padding: const EdgeInsets.all(16),
                      child: TabBarView(
                        controller: _tc,
                        children: [
                          BuildProfileTab(
                            nameController: nameController,
                            emailController: emailController,
                            phoneController: phoneController,
                            avatarController: avatarController,
                            formKey: _formKey,
                          ),
                          AddressesTab(),
                          WishlistTab(),
                          OrdersTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const FooterWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
