import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:watch_hub_ep/models/product_model.dart';
import 'package:watch_hub_ep/services/profile_service.dart';
import 'package:watch_hub_ep/models/user_model.dart';
import 'package:watch_hub_ep/models/address_model.dart';
import 'package:watch_hub_ep/widgets/catalog_screen_widget/product_list_item.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';
import 'package:watch_hub_ep/widgets/layout_widget/footer_widget.dart';

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

  bool editing = false;

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

    _srv.profileStream().listen((snap) {
      if (!snap.exists) return;
      final user = UserModel.fromDoc(snap);
      setState(() {
        nameController.text = user.name;
        emailController.text = user.email;
        phoneController.text = user.phone;
        avatarController.text = user.avatar;
      });
    });
  }

  @override
  void dispose() {
    _tc.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _fetchWishlistProducts(List<dynamic> refs) async {
    final List<ProductModel> products = [];

    for (var ref in refs) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        if (doc.exists) {
          final product = await ProductModel.fromFirestoreWithBrand(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
          products.add(product);
        }
      }
    }

    return products;
  }

  Future<void> _removeFromWishlist(String productId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance
            .collection('usersProfile')
            .doc(uid)
            .get();

    final wishlist =
        (doc.data()?['wishlist'] as List?)?.cast<DocumentReference>() ?? [];
    final updatedWishlist =
        wishlist.where((ref) => ref.id != productId).toList();

    await FirebaseFirestore.instance.collection('usersProfile').doc(uid).update(
      {'wishlist': updatedWishlist},
    );

    setState(() {});
  }

  Future<bool> isProductInCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc =
        await FirebaseFirestore.instance
            .collection('usersProfile')
            .doc(user.uid)
            .get();

    final cart = doc.data()?['cart'] as List<dynamic>?;

    if (cart == null) return false;

    return cart.any((ref) => ref is DocumentReference && ref.id == productId);
  }

  Future<void> addToCart(BuildContext context, String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add to cart.')),
      );
      context.push('/auth');
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('usersProfile')
        .doc(user.uid);

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(productId);

    await docRef.update({
      'cart': FieldValue.arrayUnion([productRef]),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product added to cart!')));
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
                          _buildProfile(context),
                          _buildAddresses(context),
                          _buildWishlist(context),
                          _buildOrders(context),
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

  Widget _buildProfile(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      avatarController.text.isNotEmpty
                          ? NetworkImage(avatarController.text)
                          : const AssetImage('assets/images/default_user.png')
                              as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    nameController.text,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: Icon(editing ? Icons.cancel : Icons.edit),
                  onPressed: () => setState(() => editing = !editing),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              enabled: editing,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              enabled: editing,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: avatarController,
              enabled: editing,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 24),
            if (editing)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _srv.updateProfile({
                        'fullName': nameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'avatarUrl': avatarController.text.trim(),
                      });
                      setState(() => editing = false);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddresses(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _srv.addressesStream(),
      builder: (ctx, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;

        return ListView(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Address'),
              onPressed: () async {
                final res = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (_) => AddressDialog(),
                );
                if (res != null) _srv.addAddress(res);
              },
            ),
            const SizedBox(height: 16),
            ...docs.map((d) {
              final a = AddressModel(d.id, d.data()!);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  title: Text(a.label),
                  subtitle: Text('${a.street}, ${a.city}, ${a.country}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _srv.removeAddress(a.id),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildWishlist(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final usersProfile = FirebaseFirestore.instance.collection('usersProfile');

    return FutureBuilder<DocumentSnapshot>(
      future: usersProfile.doc(uid).get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = userSnap.data!.data() as Map<String, dynamic>;
        final List<dynamic> wishlistRefs = data['wishlist'] ?? [];

        if (wishlistRefs.isEmpty) {
          return const Center(child: Text('No products in wishlist yet.'));
        }

        return FutureBuilder<List<ProductModel>>(
          future: _fetchWishlistProducts(wishlistRefs),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!;
            if (products.isEmpty) {
              return const Center(
                child: Text('No products found in wishlist.'),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductListItem(product: product),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remove'),
                                  onPressed:
                                      () => _removeFromWishlist(product.id),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                  ),
                                ),
                                if (product.stock > 0)
                                  FutureBuilder<bool>(
                                    future: isProductInCart(product.id),
                                    builder: (context, snapshot) {
                                      final isInCart = snapshot.data ?? false;

                                      return ElevatedButton.icon(
                                        icon: Icon(
                                          isInCart
                                              ? Icons.check
                                              : Icons.shopping_cart,
                                        ),
                                        label: Text(
                                          isInCart
                                              ? 'Already in Cart'
                                              : 'Move to Cart',
                                        ),
                                        onPressed:
                                            isInCart
                                                ? null
                                                : () async {
                                                  await addToCart(
                                                    context,
                                                    product.id,
                                                  );
                                                  // Optional: refresh parent state if needed
                                                },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          backgroundColor:
                                              isInCart ? Colors.grey : null,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrders(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _srv.ordersStream(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs;
        if (docs == null || docs.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final status = data['status'] as String? ?? 'Unknown';
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final items =
                (data['items'] as List<dynamic>? ?? [])
                    .cast<Map<String, dynamic>>();
            final total = (data['total'] as num?)?.toDouble() ?? 0.0;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order ID & Status Row
                        isMobile
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${docs[i].id}',
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        status == 'Cancelled'
                                            ? Colors.red
                                            : status == 'Shipped'
                                            ? Colors.green
                                            : Colors.orange,
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Order #${docs[i].id}',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        status == 'Cancelled'
                                            ? Colors.red
                                            : status == 'Shipped'
                                            ? Colors.green
                                            : Colors.orange,
                                  ),
                                ),
                              ],
                            ),

                        const SizedBox(height: 6),
                        Text(
                          DateFormat.yMMMd().add_jm().format(createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                        const Divider(height: 20),

                        // Order Items
                        ...items.map((item) {
                          final DocumentReference ref = item['productRef'];
                          final quantity = item['quantity'] ?? 1;

                          return FutureBuilder<DocumentSnapshot>(
                            future: ref.get(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text('• Loading product...'),
                                );
                              }

                              final productData =
                                  snap.data!.data() as Map<String, dynamic>?;
                              final title = productData?['title'] ?? 'Unknown';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text('• $title × $quantity'),
                              );
                            },
                          );
                        }).toList(),

                        const SizedBox(height: 10),
                        Text(
                          'Total: \$${total.toStringAsFixed(2)}',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 12),

                        // Buttons
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (status == 'Pending')
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text('Cancel Order'),
                                          content: const Text(
                                            'Do you really want to cancel this order?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('No'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    await _srv.cancelOrder(docs[i].id);
                                  }
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel Order'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                              ),

                            if (status == 'Shipped')
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tracking not implemented yet.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.local_shipping),
                                label: const Text('Track Order'),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AddressDialog extends StatefulWidget {
  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _form = GlobalKey<FormState>();
  final Map<String, String> model = {
    'label': '',
    'street': '',
    'city': '',
    'state': '',
    'country': '',
    'postalCode': '',
    'phone': '',
  };

  @override
  Widget build(BuildContext ctx) {
    return AlertDialog(
      title: const Text('Add Address'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            children:
                model.keys.map((field) {
                  return TextFormField(
                    decoration: InputDecoration(labelText: field),
                    onSaved: (v) => model[field] = v ?? '',
                  );
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _form.currentState!.save();
            Navigator.pop(ctx, model);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
